import 'dart:async';
import 'dart:convert';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/reader/reader_gestures.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({required this.bookId, super.key});

  final int bookId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late final BookRepository _repository;
  late final ReadiumReadingEngine _engine;

  Book? _book;
  Publication? _publication;
  Locator? _latestLocator;
  StreamSubscription<Locator>? _locatorSubscription;
  Timer? _saveTimer;
  var _progress = 0.0;
  var _loading = true;
  var _chromeVisible = false;
  var _dark = false;
  var _scroll = false;
  var _fontSize = readerFontSizeDefault;
  var _fixedLayout = false;
  var _textSelected = false;
  DateTime? _lastPageTurn;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = ref.read(bookRepositoryProvider);
    _engine = ref.read(readingEngineProvider);
    _open();
  }

  Future<void> _open() async {
    final book = await _repository.getBook(widget.bookId);
    if (!mounted) return;
    if (book == null) {
      setState(() {
        _loading = false;
        _error = 'Este libro ya no está en la biblioteca.';
      });
      return;
    }

    try {
      final publication = await _engine.open(book.filePath);
      final fixedLayout = publicationIsFixed(publication);
      await _engine.setPreferences(
        readerPreferences(
          dark: _dark,
          scroll: _scroll,
          fixedLayout: fixedLayout,
          fontSize: _fontSize,
        ),
      );
      _locatorSubscription = _engine.onLocator.listen(_onLocator);
      if (!mounted) {
        await _engine.close();
        return;
      }
      setState(() {
        _book = book;
        _publication = publication;
        _fixedLayout = fixedLayout;
        _progress = book.progress;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _openErrorMessage(error);
      });
    }
  }

  void _onLocator(Locator locator) {
    final previous = _latestLocator;
    _latestLocator = locator;
    final leftChapter =
        _textSelected && previous != null && previous.href != locator.href;
    if (leftChapter) _textSelected = false;
    final progression = locator.locations?.totalProgression;
    final progressChanged = progression != null && progression != _progress;
    if (mounted && (leftChapter || progressChanged)) {
      setState(() {
        if (progressChanged) _progress = progression;
      });
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _persist);
  }

  Future<void> _openContents() async {
    final publication = _publication;
    if (publication == null || !mounted) return;
    final entries = _contentsOf(publication);
    final selected = await showDialog<Link>(
      context: context,
      builder: (context) => _ContentsDialog(entries: entries),
    );
    if (selected == null || !mounted) return;
    final locator = publication.locatorFromLink(selected);
    if (locator == null) {
      _showMessage('No se pudo abrir este capítulo.');
      return;
    }
    _textSelected = false;
    final moved = await _engine.goToLocator(locator);
    if (!mounted) return;
    if (!moved) {
      _showMessage('No se pudo abrir este capítulo.');
      return;
    }
    setState(() => _chromeVisible = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _applyPreferences() async {
    try {
      await _engine.setPreferences(
        readerPreferences(
          dark: _dark,
          scroll: _scroll,
          fixedLayout: _fixedLayout,
          fontSize: _fontSize,
        ),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudieron aplicar los ajustes de lectura.');
      }
    }
  }

  Future<void> _toggleDark() async {
    if (_fixedLayout) {
      _showMessage(
        'En un libro de maquetación fija el color del texto no cambia.',
      );
      return;
    }
    setState(() => _dark = !_dark);
    await _applyPreferences();
  }

  Future<void> _toggleScroll() async {
    if (_fixedLayout) {
      _showMessage('Este libro se lee por páginas.');
      return;
    }
    setState(() => _scroll = !_scroll);
    await _applyPreferences();
  }

  Future<void> _changeFontSize({required bool larger}) async {
    if (_fixedLayout) {
      _showMessage(
        'En un libro de maquetación fija el tamaño del texto no cambia.',
      );
      return;
    }
    final next = stepReaderFontSize(_fontSize, larger: larger);
    if (next == _fontSize) return;
    setState(() => _fontSize = next);
    await _applyPreferences();
  }

  Future<void> _resetFontSize() async {
    if (_fixedLayout) {
      _showMessage(
        'En un libro de maquetación fija el tamaño del texto no cambia.',
      );
      return;
    }
    if (_fontSize == readerFontSizeDefault) return;
    setState(() => _fontSize = readerFontSizeDefault);
    await _applyPreferences();
  }

  void _onZone(ReaderZone zone) {
    switch (zone) {
      case ReaderZone.previous:
        _turnPage(forward: false);
      case ReaderZone.next:
        _turnPage(forward: true);
      case ReaderZone.menu:
        setState(() => _chromeVisible = !_chromeVisible);
    }
  }

  void _onTextSelected(TextSelectionEvent event) {
    if (_textSelected || !mounted) return;
    setState(() => _textSelected = true);
  }

  void _onSelectionTap() {
    if (!_textSelected || !mounted) return;
    setState(() => _textSelected = false);
  }

  Future<void> _onSelectionAction(SelectionActionEvent event) async {
    if (mounted) setState(() => _textSelected = false);
    final text = event.selectedText?.trim();
    if (text == null || text.isEmpty) return;
    switch (event.actionId) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: text));
      case 'share':
        await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  Future<void> _persist() async {
    final locator = _latestLocator;
    if (locator == null) return;
    final progress = locator.locations?.totalProgression ?? _progress;
    await _repository.saveProgress(
      id: widget.bookId,
      locatorJson: jsonEncode(locator.toJson()),
      progress: progress,
    );
  }

  Locator? _savedLocator(Book book) {
    final raw = book.locatorJson;
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Locator.fromJson(Map<String, dynamic>.from(decoded));
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/library');
    }
  }

  Future<void> _turnPage({required bool forward}) async {
    final now = DateTime.now();
    final last = _lastPageTurn;
    if (last != null &&
        now.difference(last) < const Duration(milliseconds: 350)) {
      return;
    }
    _lastPageTurn = now;
    if (_chromeVisible) setState(() => _chromeVisible = false);
    if (_scroll) {
      await _turnChapter(forward: forward);
      return;
    }
    if (forward) {
      await _engine.goForward();
    } else {
      await _engine.goBackward();
    }
  }

  Future<void> _turnChapter({required bool forward}) async {
    final publication = _publication;
    final href = _latestLocator?.href;
    if (publication == null || href == null) return;
    final chapters = publication.readingOrder.isNotEmpty
        ? publication.readingOrder
        : publication.tableOfContents;
    final index = adjacentChapterIndex(
      hrefs: [for (final link in chapters) link.href],
      currentHref: href,
      forward: forward,
    );
    if (index == null) return;
    final locator = publication.locatorFromLink(chapters[index]);
    if (locator == null) {
      _showMessage('No se pudo abrir este capítulo.');
      return;
    }
    final moved = await _engine.goToLocator(locator);
    if (!mounted) return;
    if (!moved) _showMessage('No se pudo abrir este capítulo.');
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final locator = _latestLocator;
    if (locator != null) {
      unawaited(
        _repository.saveProgress(
          id: widget.bookId,
          locatorJson: jsonEncode(locator.toJson()),
          progress: locator.locations?.totalProgression ?? _progress,
        ),
      );
    }
    unawaited(_locatorSubscription?.cancel());
    unawaited(_engine.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageColor = _dark && !_fixedLayout
        ? readerDarkBackground
        : readerLightBackground;
    return Scaffold(
      backgroundColor: _loading || _error != null ? Colors.black : pageColor,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return _statusLayer(child: const CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return _statusLayer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final publication = _publication;
    final book = _book;
    if (publication == null || book == null) {
      return _statusLayer(child: const Text('No se pudo abrir el libro.'));
    }

    final rtl =
        publication.metadata.readingProgression == ReadingProgression.rtl;

    return Stack(
      children: [
        Positioned(
          top: readerProgressClearance,
          left: 0,
          right: 0,
          bottom: 0,
          child: ReadiumReaderWidget(
            publication: publication,
            initialLocator: _savedLocator(book),
            allowedDefaultActions: const {
              DefaultSelectionAction.copy,
              DefaultSelectionAction.share,
            },
            selectionActions: defaultTargetPlatform == TargetPlatform.android
                ? _androidSelectionActions
                : const [],
            onTextSelected: _onTextSelected,
            onSelectionAction: _onSelectionAction,
          ),
        ),
        Positioned(
          top: readerProgressClearance,
          left: 0,
          right: 0,
          bottom: 0,
          child: ReaderGestureLayer(
            rtl: rtl,
            scroll: _scroll,
            textSelected: _textSelected,
            onZone: _onZone,
            onSwipe: (forward) => _turnPage(forward: forward),
            onSelectionTap: _onSelectionTap,
          ),
        ),
        Positioned(top: 0, left: 0, right: 0, child: _readerChrome()),
      ],
    );
  }

  Widget _statusLayer({required Widget child}) {
    return Stack(
      children: [
        Center(
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Color(0xFFF7F1E8)),
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _readerChrome(forceVisible: true),
        ),
      ],
    );
  }

  Widget _readerChrome({bool forceVisible = false}) {
    final visible = forceVisible || _chromeVisible;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: LinearProgressIndicator(
            minHeight: 3,
            value: _loading ? null : _progress.clamp(0, 1),
            backgroundColor: const Color(0x33000000),
            color: const Color(0xFF6B4F3A),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Material(
              color: const Color(0xF2F7F1E8),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (_publication != null) ...[
                      IconButton(
                        tooltip: 'Índice',
                        onPressed: _openContents,
                        icon: const Icon(Icons.format_list_bulleted),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? 'En este libro el color del texto no cambia'
                            : (_dark ? 'Modo claro' : 'Modo oscuro'),
                        onPressed: _toggleDark,
                        icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? 'Este libro se lee por páginas'
                            : (_scroll
                                  ? 'Lectura por páginas'
                                  : 'Lectura con scroll'),
                        onPressed: _toggleScroll,
                        icon: Icon(_scroll ? Icons.menu_book : Icons.swap_vert),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? 'En este libro el tamaño del texto no cambia'
                            : 'Reducir texto',
                        onPressed: () => _changeFontSize(larger: false),
                        icon: const Icon(Icons.text_decrease),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? 'En este libro el tamaño del texto no cambia'
                            : 'Tamaño original',
                        onPressed: _resetFontSize,
                        icon: const _OriginalFontMark(),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? 'En este libro el tamaño del texto no cambia'
                            : 'Aumentar texto',
                        onPressed: () => _changeFontSize(larger: true),
                        icon: const Icon(Icons.text_increase),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: _close,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OriginalFontMark extends StatelessWidget {
  const _OriginalFontMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'A0',
      style: TextStyle(
        color: IconTheme.of(context).color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }
}

/// Android ignores [DefaultSelectionAction] and only reports a selection when
/// custom actions replace its system menu.
const _androidSelectionActions = [
  SelectionAction(id: 'copy', title: 'Copiar'),
  SelectionAction(id: 'share', title: 'Compartir'),
];

class _TocEntry {
  const _TocEntry({required this.link, required this.depth});

  final Link link;
  final int depth;

  String get title {
    final title = link.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return 'Sin título';
  }
}

List<_TocEntry> _contentsOf(Publication publication) {
  final source = publication.tableOfContents.isNotEmpty
      ? publication.tableOfContents
      : publication.readingOrder;
  final entries = <_TocEntry>[];
  void walk(List<Link> links, int depth) {
    for (final link in links) {
      entries.add(_TocEntry(link: link, depth: depth));
      walk(link.children, depth + 1);
    }
  }

  walk(source, 0);
  return entries;
}

class _ContentsDialog extends StatelessWidget {
  const _ContentsDialog({required this.entries});

  final List<_TocEntry> entries;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.6;
    return AlertDialog(
      title: const Text('Índice'),
      content: SizedBox(
        width: double.maxFinite,
        height: height,
        child: entries.isEmpty
            ? const Text('Este libro no tiene índice.')
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                      left: 16 + entry.depth * 16,
                      right: 16,
                    ),
                    title: Text(entry.title),
                    onTap: () => Navigator.pop(context, entry.link),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

String _openErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('MethodNotImplemented') ||
      text.contains('not implemented')) {
    return 'El lector funciona en iOS y Android. En el escritorio de macOS Readium no abre el EPUB.';
  }
  return 'No se pudo abrir el libro.';
}
