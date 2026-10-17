import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/habits/book_reading_block.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/month_reading_card.dart';
import 'package:epub_reader/features/habits/month_report_document.dart';
import 'package:epub_reader/features/habits/month_report_store.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MonthLink {
  const MonthLink(this.month, {this.draft = false});

  final DateTime month;
  final bool draft;
}

class MonthReadingPage extends ConsumerStatefulWidget {
  const MonthReadingPage({this.month, super.key});

  /// The month to show. Empty opens the month currently on review.
  final DateTime? month;

  @override
  ConsumerState<MonthReadingPage> createState() => _MonthReadingPageState();
}

class _MonthReadingPageState extends ConsumerState<MonthReadingPage> {
  final _export = MonthCardExport();
  var _sharing = false;
  var _closing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(readingSessionsProvider);
    final books = ref.watch(booksProvider);
    final quotes = ref.watch(savedQuotesProvider);
    final reports = ref.watch(monthReportsProvider);
    final plans = ref.watch(readingPlanVersionsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: l10n.back,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: _body(
                context,
                l10n,
                sessions: sessions,
                books: books,
                quotes: quotes,
                reports: reports,
                plans: plans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n, {
    required AsyncValue<List<ReadingSession>> sessions,
    required AsyncValue<List<Book>> books,
    required AsyncValue<List<ReadingQuote>> quotes,
    required AsyncValue<List<MonthReport>> reports,
    required AsyncValue<List<ReadingPlanVersion>> plans,
  }) {
    if (sessions.hasError) {
      return _Message(text: l10n.readingTimeLoadFailed('${sessions.error}'));
    }
    if (books.hasError) {
      return _Message(text: l10n.readingTimeLoadFailed('${books.error}'));
    }
    if (quotes.hasError) {
      return _Message(text: l10n.readingTimeLoadFailed('${quotes.error}'));
    }
    if (reports.hasError) {
      return _Message(text: l10n.readingTimeLoadFailed('${reports.error}'));
    }
    if (plans.hasError) {
      return _Message(text: l10n.readingTimeLoadFailed('${plans.error}'));
    }
    if (!sessions.hasValue ||
        !books.hasValue ||
        !quotes.hasValue ||
        !reports.hasValue ||
        !plans.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    final now = DateTime.now();
    final sessionRows = sessions.requireValue;
    final bookRows = books.requireValue;
    final reportRows = reports.requireValue;
    final quoteRows = [
      for (final quote in quotes.requireValue)
        MonthQuoteInput(
          id: quote.id,
          bookId: quote.bookId,
          savedAt: quote.savedAt,
          text: quote.text,
          bookTitle: quote.bookTitle,
        ),
    ];
    final planRows = [
      for (final plan in plans.requireValue)
        MonthPlanVersion(
          effectiveAt: plan.effectiveAt,
          dailyGoalMinutes: plan.dailyGoalMinutes,
          routineHour: plan.routineHour,
          weekdays: monthPlanWeekdays(plan.routineDays),
        ),
    ];
    final archived = [
      for (final row in reportRows) DateTime(row.year, row.month),
    ];
    final selected =
        widget.month ??
        monthOnReview(sessions: sessionRows, now: now) ??
        _latestMonth(reportRows, sessionRows, now);
    if (_elapsedPending(sessionRows, archived, now)) {
      _closeElapsed(
        sessions: sessionRows,
        books: bookRows,
        quotes: quoteRows,
        plans: planRows,
        now: now,
      );
    }
    if (selected != null &&
        monthSnapshotPending(
          month: selected,
          sessions: sessionRows,
          archived: archived,
          now: now,
        )) {
      return const Center(child: CircularProgressIndicator());
    }
    final report = _shown(
      selected: selected,
      reports: reportRows,
      sessions: sessionRows,
      books: bookRows,
      quotes: quoteRows,
      plans: planRows,
      now: now,
    );
    return MonthReadingView(
      report: report,
      links: _links(
        selected: selected,
        reports: reportRows,
        sessions: sessionRows,
        now: now,
      ),
      sharing: _sharing,
      onRead: (bookId) =>
          context.push(readingRoute(bookId, readingSourceLibrary)),
      onOpenMonth: (month) =>
          context.replace('/profile/month/${month.year}/${month.month}'),
      onShare: (copy, origin) => _share(copy, origin),
    );
  }

  bool _elapsedPending(
    List<ReadingSession> sessions,
    List<DateTime> archived,
    DateTime now,
  ) {
    final current = readingMonthOf(now);
    final seen = <DateTime>{};
    for (final session in sessions) {
      final month = readingMonthOf(session.startedAt);
      if (!month.isBefore(current) || !seen.add(month)) continue;
      if (monthSnapshotPending(
        month: month,
        sessions: sessions,
        archived: archived,
        now: now,
      )) {
        return true;
      }
    }
    return false;
  }

  void _closeElapsed({
    required List<ReadingSession> sessions,
    required List<Book> books,
    required List<MonthQuoteInput> quotes,
    required List<MonthPlanVersion> plans,
    required DateTime now,
  }) {
    if (_closing) return;
    _closing = true;
    ref
        .read(monthReportStoreProvider)
        .closeElapsed(
          sessions: sessions,
          books: books,
          quotes: quotes,
          plans: plans,
          now: now,
        )
        .whenComplete(() {
          if (!mounted) return;
          setState(() => _closing = false);
        });
  }

  MonthReadingReport? _shown({
    required DateTime? selected,
    required List<MonthReport> reports,
    required List<ReadingSession> sessions,
    required List<Book> books,
    required List<MonthQuoteInput> quotes,
    required List<MonthPlanVersion> plans,
    required DateTime now,
  }) {
    if (selected == null) return null;
    final saved = _stored(reports, selected);
    if (saved != null && monthIsClosed(selected, now)) {
      return monthReportInLibrary(
        decodeMonthReport(saved.document, month: selected),
        books,
      );
    }
    if (monthIsClosed(selected, now)) return null;
    final previous = DateTime(selected.year, selected.month - 1);
    final archivedPrevious = _stored(reports, previous);
    return monthReadingReport(
      sessions: sessions,
      books: books,
      quotes: quotes,
      plans: plans,
      now: now,
      month: selected,
      archivedPreviousSeconds: archivedPrevious == null
          ? null
          : decodeMonthReport(
              archivedPrevious.document,
              month: previous,
            ).engagedSeconds,
    );
  }

  List<MonthLink> _links({
    required DateTime? selected,
    required List<MonthReport> reports,
    required List<ReadingSession> sessions,
    required DateTime now,
  }) {
    final current = readingMonthOf(now);
    final links = <MonthLink>[];
    if (monthHasReading(sessions, current) && !_sameMonth(selected, current)) {
      links.add(MonthLink(current, draft: true));
    }
    for (final row in reports) {
      final month = DateTime(row.year, row.month);
      if (_sameMonth(selected, month)) continue;
      links.add(MonthLink(month));
    }
    return links;
  }

  DateTime? _latestMonth(
    List<MonthReport> reports,
    List<ReadingSession> sessions,
    DateTime now,
  ) {
    final current = readingMonthOf(now);
    DateTime? latest;
    if (monthHasReading(sessions, current)) latest = current;
    for (final row in reports) {
      final month = DateTime(row.year, row.month);
      if (latest == null ||
          month.year > latest.year ||
          (month.year == latest.year && month.month > latest.month)) {
        latest = month;
      }
    }
    return latest;
  }

  MonthReport? _stored(List<MonthReport> reports, DateTime month) {
    for (final row in reports) {
      if (row.year == month.year && row.month == month.month) return row;
    }
    return null;
  }

  bool _sameMonth(DateTime? left, DateTime right) {
    return left != null && left.year == right.year && left.month == right.month;
  }

  Future<void> _share(MonthCardCopy copy, Rect? origin) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final l10n = AppLocalizations.of(context);
    try {
      final png = await renderMonthCard(
        copy,
        colors: ScheduleColors.of(context),
        look: ScheduleLook.of(context),
      );
      final file = await _export.writePng(png);
      if (!mounted) return;
      await _export.share(file.path, origin: origin);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.monthShareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class MonthReadingView extends StatelessWidget {
  const MonthReadingView({
    required this.report,
    required this.onRead,
    required this.onShare,
    this.links = const [],
    this.onOpenMonth,
    this.sharing = false,
    super.key,
  });

  final MonthReadingReport? report;
  final ValueChanged<int> onRead;
  final void Function(MonthCardCopy copy, Rect? origin) onShare;
  final List<MonthLink> links;
  final ValueChanged<DateTime>? onOpenMonth;
  final bool sharing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = this.report;
    final code = Localizations.localeOf(context).languageCode;
    if (report == null) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScheduleHeader(title: l10n.monthReading),
          const ScheduleRule(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.monthReadingEmpty, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    final headline = _headline(l10n, report, code);
    final minutes = formatReadingDuration(report.engagedSeconds);
    final archetype = report.archetype;
    final quote = report.quote;
    final older = _monthNeighbor(report.month, links, newer: false);
    final newer = _monthNeighbor(report.month, links, newer: true);
    final open = onOpenMonth;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (open == null) return;
        final velocity = details.primaryVelocity ?? 0;
        final month = velocity <= -500
            ? newer
            : velocity >= 500
            ? older
            : null;
        if (month != null) open(month);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _MonthTitle(
            title: scheduleMonthTitle(report.month.month, code),
            onPrevious: older == null || open == null
                ? null
                : () => open(older),
            onNext: newer == null || open == null ? null : () => open(newer),
          ),
          const ScheduleRule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: Theme.of(context).textTheme.bodyLarge),
                if (report.metDays != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    minutes,
                    style: programTitle(
                      context,
                      ScheduleColors.of(context).ink,
                      size: 28,
                    ),
                  ),
                ],
                if (report.minuteDeltaSeconds != null &&
                    report.comparedMonth != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _comparison(l10n, report, code),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ScheduleColors.of(context).muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (final book in report.books)
            ScheduleListing(
              key: ValueKey(book.bookId),
              title: _title(book.title, l10n),
              subtitle: _bookSubtitle(l10n, book),
              trailing: formatReadingDuration(book.engagedSeconds),
              cover: book.coverBytes,
              progress: book.progress,
              onTap: book.available ? () => onRead(book.bookId) : null,
            ),
          if (archetype != null) ...[
            if (report.books.isEmpty) const ScheduleRule(),
            _ArchetypeBlock(report: archetype),
          ],
          if (quote != null) ...[
            if (report.books.isEmpty || archetype != null) const ScheduleRule(),
            _QuoteBlock(quote: quote),
          ],
          if (report.books.isEmpty || archetype != null || quote != null)
            const ScheduleRule(),
          Builder(
            builder: (context) {
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: sharing
                      ? null
                      : () => onShare(
                          MonthCardCopy(
                            month: scheduleMonthTitle(report.month.month, code),
                            headline: headline,
                            minutes: minutes,
                            archetype: archetype == null
                                ? null
                                : _archetypeName(l10n, archetype.kind),
                          ),
                          _shareOrigin(context),
                        ),
                  child: Text(l10n.share),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthTitle extends StatelessWidget {
  const _MonthTitle({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousMonth,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: ios ? 34 : 28,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: colors.ink,
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.nextMonth,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

DateTime? _monthNeighbor(
  DateTime selected,
  List<MonthLink> links, {
  required bool newer,
}) {
  final months = [selected, for (final link in links) link.month]
    ..sort((a, b) {
      final year = a.year.compareTo(b.year);
      return year != 0 ? year : a.month.compareTo(b.month);
    });
  final index = months.indexWhere(
    (month) => month.year == selected.year && month.month == selected.month,
  );
  final next = newer ? index + 1 : index - 1;
  if (next < 0 || next >= months.length) return null;
  return months[next];
}

class _ArchetypeBlock extends StatelessWidget {
  const _ArchetypeBlock({required this.report});

  final MonthArchetypeReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _archetypeName(l10n, report.kind),
            style: programTitle(context, colors.ink, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            _archetypePhrase(l10n, report.kind),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            _archetypeEvidence(l10n, report.evidence),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.quote});

  final MonthQuoteLine quote;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final title = quote.bookTitle.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.passage,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

String _headline(
  AppLocalizations l10n,
  MonthReadingReport report,
  String languageCode,
) {
  final month = _sentenceMonth(report.month, languageCode);
  final met = report.metDays;
  final planned = report.plannedDays;
  if (met != null && planned != null) {
    return l10n.monthPlanDays(month, met, planned);
  }
  return l10n.monthReadTime(
    month,
    formatReadingDuration(report.engagedSeconds),
  );
}

String _comparison(
  AppLocalizations l10n,
  MonthReadingReport report,
  String languageCode,
) {
  final delta = report.minuteDeltaSeconds ?? 0;
  final month = _sentenceMonth(report.comparedMonth!, languageCode);
  final duration = formatReadingDuration(delta.abs());
  if (delta > 0) return l10n.monthMinutesMore(duration, month);
  return l10n.monthMinutesLess(duration, month);
}

String? _bookSubtitle(AppLocalizations l10n, MonthBookLine book) {
  if (book.finished) return l10n.monthBookFinished;
  final horizon = book.horizon;
  if (horizon == null) return null;
  return readingHorizonLabel(l10n, horizon);
}

String _title(String title, AppLocalizations l10n) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

String _sentenceMonth(DateTime month, String languageCode) {
  if (languageCode == 'en') {
    return scheduleMonthTitle(month.month, languageCode);
  }
  return scheduleMonthName(month.month, languageCode);
}

String _archetypeName(AppLocalizations l10n, MonthArchetype kind) {
  return switch (kind) {
    MonthArchetype.methodical => l10n.monthMethodical,
    MonthArchetype.ant => l10n.monthAnt,
    MonthArchetype.marathoner => l10n.monthMarathoner,
    MonthArchetype.ideaHunter => l10n.monthHunter,
    MonthArchetype.earlyRiser => l10n.monthEarly,
    MonthArchetype.afternoon => l10n.monthAfternoon,
    MonthArchetype.nightOwl => l10n.monthNight,
    MonthArchetype.nomad => l10n.monthNomad,
  };
}

String _archetypePhrase(AppLocalizations l10n, MonthArchetype kind) {
  return switch (kind) {
    MonthArchetype.methodical => l10n.monthMethodicalPhrase,
    MonthArchetype.ant => l10n.monthAntPhrase,
    MonthArchetype.marathoner => l10n.monthMarathonerPhrase,
    MonthArchetype.ideaHunter => l10n.monthHunterPhrase,
    MonthArchetype.earlyRiser => l10n.monthEarlyPhrase,
    MonthArchetype.afternoon => l10n.monthAfternoonPhrase,
    MonthArchetype.nightOwl => l10n.monthNightPhrase,
    MonthArchetype.nomad => l10n.monthNomadPhrase,
  };
}

String _archetypeEvidence(
  AppLocalizations l10n,
  MonthArchetypeEvidence evidence,
) {
  return switch (evidence) {
    MethodicalEvidence(:final onTime, :final sessions, :final hour) =>
      l10n.monthMethodicalEvidence(onTime, sessions, readingHourLabel(hour)),
    AntEvidence(:final metDays, :final plannedDays) => l10n.monthAntEvidence(
      metDays,
      plannedDays,
    ),
    MarathonerEvidence(:final averageSeconds) => l10n.monthMarathonerEvidence(
      formatReadingDuration(averageSeconds),
    ),
    HunterEvidence(:final sessionsWithQuotes, :final sessions) =>
      l10n.monthHunterEvidence(sessionsWithQuotes, sessions),
    BandEvidence(:final percent) => l10n.monthBandEvidence(percent),
    NomadEvidence() => l10n.monthNomadEvidence,
  };
}

Rect? _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
