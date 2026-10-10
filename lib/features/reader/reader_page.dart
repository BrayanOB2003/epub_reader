import 'dart:async';
import 'dart:convert';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/habits/reading_engagement.dart';
import 'package:epub_reader/features/notifications/reading_notifications.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/reader/reader_gestures.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({
    required this.bookId,
    this.source = readingSourceLibrary,
    this.quoteId,
    super.key,
  });

  final int bookId;
  final String source;
  final int? quoteId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage>
    with WidgetsBindingObserver {
  late final BookRepository _repository;
  late final ReadiumReadingEngine _engine;
  late final AppAnalytics _analytics;
  late final ReaderProfileStore _profiles;

  Book? _book;
  Publication? _publication;
  Locator? _initialLocator;
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
  ReadingEngagement? _engagement;
  int? _readingSessionId;
  Future<void> _sessionWrite = Future<void>.value();
  var _sessionReported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = ref.read(bookRepositoryProvider);
    _engine = ref.read(readingEngineProvider);
    _analytics = ref.read(appAnalyticsProvider);
    _profiles = ref.read(readerProfileStoreProvider);
    _open();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final engagement = _engagement;
    if (engagement == null) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      engagement.background();
      _syncEngagement();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      engagement.resume();
    }
  }

  Future<void> _open() async {
    final book = await _repository.getBook(widget.bookId);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (book == null) {
      setState(() {
        _loading = false;
        _error = l10n.bookGone;
      });
      return;
    }

    try {
      _initialLocator = await _locatorForOpening(book);
      final publication = await _engine.open(book.filePath);
      final fixedLayout = publicationIsFixed(publication);
      _dark = book.darkMode;
      _scroll = book.scrollMode;
      _fontSize = book.fontSize.clamp(readerFontSizeMin, readerFontSizeMax);
      await _engine.setPreferences(
        readerPreferences(
          dark: _dark,
          scroll: _scroll,
          fixedLayout: fixedLayout,
          fontSize: _fontSize,
        ),
      );
      _engagement = ReadingEngagement();
      _locatorSubscription = _engine.onLocator.listen(_onLocator);
      if (!mounted) {
        _engagement?.abandon();
        await _engine.close();
        return;
      }
      setState(() {
        _book = book;
        _publication = publication;
        _fixedLayout = fixedLayout;
        _progress = _bookProgress(_initialLocator) ?? book.progress;
        _loading = false;
      });
    } catch (error, stack) {
      unawaited(_analytics.recordUnexpected('reader_open_failed', stack));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _openErrorMessage(l10n, error);
      });
    }
  }

  double? _bookProgress(Locator? locator) {
    final order = _publication?.readingOrder;
    return readingProgress(
      locator: locator,
      hrefs: [for (final link in order ?? const <Link>[]) link.href],
    );
  }

  void _onLocator(Locator locator) {
    final previous = _latestLocator;
    _latestLocator = locator;
    final leftChapter =
        _textSelected && previous != null && previous.href != locator.href;
    if (leftChapter) _textSelected = false;
    final progression = _bookProgress(locator);
    final progressChanged = progression != null && progression != _progress;
    if (mounted && (leftChapter || progressChanged)) {
      setState(() {
        if (progressChanged) _progress = progression;
      });
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _persist);
    _engagement?.onSpot(readingSpotFromLocator(locator));
    _syncEngagement();
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
      _showMessage(AppLocalizations.of(context).chapterFailed);
      return;
    }
    _textSelected = false;
    final moved = await _engine.goToLocator(locator);
    if (!mounted) return;
    if (!moved) {
      _showMessage(AppLocalizations.of(context).chapterFailed);
      return;
    }
    setState(() => _chromeVisible = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _applyPreferences() async {
    _engagement?.preferencesChanged();
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
        _showMessage(AppLocalizations.of(context).preferencesFailed);
      }
    }
  }

  Future<void> _toggleDark() async {
    if (_fixedLayout) {
      _showMessage(AppLocalizations.of(context).fixedColor);
      return;
    }
    setState(() => _dark = !_dark);
    await _commitPreferences();
  }

  Future<void> _toggleScroll() async {
    if (_fixedLayout) {
      _showMessage(AppLocalizations.of(context).fixedPages);
      return;
    }
    setState(() => _scroll = !_scroll);
    await _commitPreferences();
  }

  Future<void> _changeFontSize({required bool larger}) async {
    if (_fixedLayout) {
      _showMessage(AppLocalizations.of(context).fixedSize);
      return;
    }
    final next = stepReaderFontSize(_fontSize, larger: larger);
    if (next == _fontSize) return;
    setState(() => _fontSize = next);
    await _commitPreferences();
  }

  Future<void> _resetFontSize() async {
    if (_fixedLayout) {
      _showMessage(AppLocalizations.of(context).fixedSize);
      return;
    }
    if (_fontSize == readerFontSizeDefault) return;
    setState(() => _fontSize = readerFontSizeDefault);
    await _commitPreferences();
  }

  Future<void> _commitPreferences() async {
    await _applyPreferences();
    try {
      await _repository.saveReadingSettings(
        id: widget.bookId,
        darkMode: _dark,
        scrollMode: _scroll,
        fontSize: _fontSize,
      );
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).preferencesSaveFailed);
      }
    }
  }

  void _hideChrome() {
    if (!_chromeVisible || !mounted) return;
    setState(() => _chromeVisible = false);
  }

  void _onZone(ReaderZone zone) {
    if (_textSelected) return;
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
    final text = event.selectedText?.trim();
    if (text == null || text.isEmpty || !mounted || _textSelected) return;
    setState(() => _textSelected = true);
  }

  void _onSelectionTap() => _clearSelection();

  void _clearSelection() {
    if (!_textSelected || !mounted) return;
    setState(() => _textSelected = false);
  }

  Future<void> _onSelectionAction(SelectionActionEvent event) async {
    if (event.actionId != 'save') return;
    final text = event.selectedText?.trim();
    if (text == null || text.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    try {
      await _repository.saveQuote(
        bookId: widget.bookId,
        text: text,
        locatorJson: jsonEncode(event.locator.toJson()),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.quoteSaveFailed);
      return;
    }
    if (!mounted) return;
    _showMessage(l10n.quoteSaved);
  }

  Future<void> _persist() async {
    final locator = _latestLocator;
    if (locator == null) return;
    final progress = _bookProgress(locator) ?? _progress;
    await _repository.saveProgress(
      id: widget.bookId,
      locatorJson: jsonEncode(locator.toJson()),
      progress: progress,
    );
  }

  Future<Locator?> _locatorForOpening(Book book) async {
    final quoteId = widget.quoteId;
    if (quoteId != null) {
      final quote = await _repository.quoteById(quoteId);
      if (quote != null && quote.bookId == book.id) {
        final locator = _locatorFromJson(quote.locatorJson);
        if (locator != null) return locator;
      }
    }
    return _savedLocator(book);
  }

  Locator? _savedLocator(Book book) => _locatorFromJson(book.locatorJson);

  Locator? _locatorFromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return Locator.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  void _close() {
    _engagement?.close();
    _syncEngagement();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/library');
    }
  }

  void _syncEngagement() {
    final engagement = _engagement;
    if (engagement == null || !engagement.shouldPersist) return;
    final startedAt = engagement.startedAt;
    final endedAt = engagement.endedAt ?? startedAt;
    _sessionWrite = _sessionWrite.then((_) async {
      if (!engagement.shouldPersist) return;
      try {
        final existing = _readingSessionId;
        if (existing == null) {
          _readingSessionId = await _repository.insertReadingSession(
            bookId: widget.bookId,
            startedAt: startedAt,
            endedAt: engagement.endedAt ?? endedAt,
            engagedSeconds: engagement.engagedSeconds,
          );
        } else {
          await _repository.updateReadingSession(
            id: existing,
            endedAt: engagement.endedAt ?? endedAt,
            engagedSeconds: engagement.engagedSeconds,
          );
        }
      } catch (_) {}
    });
  }

  Future<void> _reportSession() async {
    if (_sessionReported) return;
    _sessionReported = true;
    await _sessionWrite;
    final engagement = _engagement;
    if (engagement == null ||
        !engagement.shouldPersist ||
        _readingSessionId == null) {
      return;
    }
    await _analytics.logReadingSession(
      engagedSeconds: engagement.engagedSeconds,
      advanced: engagement.advanced,
      source: widget.source,
    );
    final goalMinutes = (await _profiles.current())?.dailyGoalMinutes;
    if (goalMinutes == null) return;
    final rows = await _repository.loadReadingSessions();
    final crossed = sessionCrossedReadingGoal(
      sessions: [
        for (final row in rows)
          NotificationSession(
            bookId: row.bookId,
            startedAt: row.startedAt,
            endedAt: row.endedAt,
            engagedSeconds: row.engagedSeconds,
          ),
      ],
      sessionStartedAt: engagement.startedAt,
      sessionSeconds: engagement.engagedSeconds,
      goalMinutes: goalMinutes,
      now: DateTime.now(),
    );
    if (!crossed) return;
    await _analytics.logDailyGoalReached();
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
      _showMessage(AppLocalizations.of(context).chapterFailed);
      return;
    }
    final moved = await _engine.goToLocator(locator);
    if (!mounted) return;
    if (!moved) {
      _showMessage(AppLocalizations.of(context).chapterFailed);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _engagement?.close();
    _syncEngagement();
    unawaited(_reportSession());
    _saveTimer?.cancel();
    final locator = _latestLocator;
    if (locator != null) {
      unawaited(
        _repository.saveProgress(
          id: widget.bookId,
          locatorJson: jsonEncode(locator.toJson()),
          progress: _bookProgress(locator) ?? _progress,
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
      return _statusLayer(child: Text(AppLocalizations.of(context).openFailed));
    }

    final rtl =
        publication.metadata.readingProgression == ReadingProgression.rtl;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Positioned(
          top: readerProgressClearance,
          left: 0,
          right: 0,
          bottom: 0,
          child: ReadiumReaderWidget(
            publication: publication,
            initialLocator: _initialLocator,
            allowedDefaultActions: const {
              DefaultSelectionAction.copy,
              DefaultSelectionAction.share,
            },
            selectionActions: [
              SelectionAction(id: 'save', title: l10n.saveQuote),
            ],
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
            onPageDrag: _hideChrome,
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
            style: const TextStyle(color: Color(0xFFF4F7FB)),
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
    final l10n = AppLocalizations.of(context);
    final visible = forceVisible || _chromeVisible;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: LinearProgressIndicator(
            minHeight: 3,
            value: _loading ? null : _progress.clamp(0, 1),
            backgroundColor: const Color(0x330E1A2B),
            color: const Color(0xFF0C4DA2),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Material(
              color: const Color(0xF2F4F7FB),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (_publication != null) ...[
                      IconButton(
                        tooltip: l10n.contents,
                        onPressed: _openContents,
                        icon: const Icon(Icons.format_list_bulleted),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? l10n.fixedColorShort
                            : (_dark ? l10n.lightMode : l10n.darkMode),
                        onPressed: _toggleDark,
                        icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? l10n.fixedPagesShort
                            : (_scroll ? l10n.pageMode : l10n.scrollMode),
                        onPressed: _toggleScroll,
                        icon: Icon(_scroll ? Icons.menu_book : Icons.swap_vert),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? l10n.fixedSizeShort
                            : l10n.smallerText,
                        onPressed: () => _changeFontSize(larger: false),
                        icon: const Icon(Icons.text_decrease),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? l10n.fixedSizeShort
                            : l10n.originalSize,
                        onPressed: _resetFontSize,
                        icon: const _OriginalFontMark(),
                      ),
                      IconButton(
                        tooltip: _fixedLayout
                            ? l10n.fixedSizeShort
                            : l10n.largerText,
                        onPressed: () => _changeFontSize(larger: true),
                        icon: const Icon(Icons.text_increase),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.close,
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

class _TocEntry {
  const _TocEntry({required this.link, required this.depth});

  final Link link;
  final int depth;

  String title(String untitled) {
    final title = link.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return untitled;
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
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.6;
    return AlertDialog(
      title: Text(l10n.contents),
      content: SizedBox(
        width: double.maxFinite,
        height: height,
        child: entries.isEmpty
            ? Text(l10n.noContents)
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                      left: 16 + entry.depth * 16,
                      right: 16,
                    ),
                    title: Text(entry.title(l10n.untitled)),
                    onTap: () => Navigator.pop(context, entry.link),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

String _openErrorMessage(AppLocalizations l10n, Object error) {
  final text = error.toString();
  if (text.contains('MethodNotImplemented') ||
      text.contains('not implemented')) {
    return l10n.readerDesktopOnly;
  }
  return l10n.openFailed;
}
