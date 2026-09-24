import 'dart:async';
import 'dart:convert';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/reader/reader_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  var _page = 1;
  int? _totalPages;
  int? _dragPage;
  var _loading = true;
  var _chromeVisible = false;
  DateTime? _lastPageTurn;
  var _swipeDx = 0.0;
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
      _locatorSubscription = _engine.onLocator.listen(_onLocator);
      if (!mounted) {
        await _engine.close();
        return;
      }
      final saved = _savedLocator(book);
      setState(() {
        _book = book;
        _publication = publication;
        _progress = book.progress;
        _loading = false;
        if (saved != null) _rememberPage(saved);
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
    _latestLocator = locator;
    final progression = locator.locations?.totalProgression;
    if (mounted) {
      setState(() {
        if (progression != null) _progress = progression;
        if (_dragPage == null) _rememberPage(locator);
      });
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _persist);
  }

  void _rememberPage(Locator locator) {
    final page = bookPage(locator);
    if (page != null) {
      _page = page;
      final known = _totalPages;
      if (known != null && page > known) _totalPages = page;
    }
    _totalPages ??= estimatedTotalPages(position: page, totalProgression: locator.locations?.totalProgression);
  }

  Future<void> _goToPage(int page) async {
    final publication = _publication;
    final total = _totalPages;
    if (publication == null || total == null || total < 2 || page == _page) return;
    final order = publication.readingOrder;
    final target = spineTarget(page: page, total: total, chapterCount: order.length);
    if (order.isEmpty) return;
    final locator = publication.locatorFromLink(order[target.index]);
    if (locator == null) return;
    await _engine.goToLocator(locator.copyWithLocations(progression: target.progression));
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
    if (last != null && now.difference(last) < const Duration(milliseconds: 350)) return;
    _lastPageTurn = now;
    if (_chromeVisible) setState(() => _chromeVisible = false);
    if (forward) {
      await _engine.goForward();
    } else {
      await _engine.goBackward();
    }
  }

  void _onSwipeEnd(DragEndDetails details, {required bool rtl}) {
    const minVelocity = 250.0;
    const minDistance = 48.0;
    final velocity = details.primaryVelocity ?? 0;
    final distance = _swipeDx;
    final swipedLeft = velocity <= -minVelocity || (velocity.abs() < minVelocity && distance <= -minDistance);
    final swipedRight = velocity >= minVelocity || (velocity.abs() < minVelocity && distance >= minDistance);
    if (!swipedLeft && !swipedRight) return;
    _turnPage(forward: swipedLeft ? !rtl : rtl);
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
    return Scaffold(
      backgroundColor: Colors.black,
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

    final rtl = publication.metadata.readingProgression == ReadingProgression.rtl;

    return Stack(
      children: [
        Positioned.fill(child: ReadiumReaderWidget(publication: publication, initialLocator: _savedLocator(book))),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _swipeDx = 0,
            onHorizontalDragUpdate: (details) => _swipeDx += details.delta.dx,
            onHorizontalDragEnd: (details) => _onSwipeEnd(details, rtl: rtl),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _TapZone(
                    label: rtl ? 'Página siguiente' : 'Página anterior',
                    onTap: () => _turnPage(forward: rtl),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _TapZone(
                    label: 'Mostrar menú',
                    onTap: () => setState(() => _chromeVisible = !_chromeVisible),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _TapZone(
                    label: rtl ? 'Página anterior' : 'Página siguiente',
                    onTap: () => _turnPage(forward: !rtl),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(top: 0, left: 0, right: 0, child: _readerChrome()),
        Positioned(left: 0, right: 0, bottom: 0, child: _pageChrome()),
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
        Positioned(top: 0, left: 0, right: 0, child: _readerChrome(forceVisible: true)),
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Cerrar',
                    onPressed: _close,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageChrome() {
    final total = _totalPages ?? _page;
    final page = (_dragPage ?? _page).clamp(1, total);
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.bottomCenter,
        heightFactor: _chromeVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Material(
          color: const Color(0xF2F7F1E8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Página $page de $total', style: Theme.of(context).textTheme.labelLarge),
                Slider(
                  value: page.toDouble(),
                  min: 1,
                  max: total > 1 ? total.toDouble() : 2,
                  activeColor: const Color(0xFF6B4F3A),
                  label: '$page',
                  onChanged: total < 2
                      ? null
                      : (value) => setState(() => _dragPage = value.round().clamp(1, total).toInt()),
                  onChangeEnd: (value) {
                    final target = value.round().clamp(1, total).toInt();
                    setState(() => _dragPage = null);
                    _goToPage(target);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TapZone extends StatelessWidget {
  const _TapZone({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}

String _openErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('MethodNotImplemented') || text.contains('not implemented')) {
    return 'El lector funciona en iOS y Android. En el escritorio de macOS Readium no abre el EPUB.';
  }
  return 'No se pudo abrir el libro.';
}
