import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/habits/book_reading_block.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/month_report_store.dart';
import 'package:epub_reader/features/habits/reading_calendar.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/habits/weekly_reading_chart.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingTimePage extends ConsumerWidget {
  const ReadingTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(readingSessionsProvider);
    final plansAsync = ref.watch(readingPlanVersionsProvider);
    final goalMinutes = ref
        .watch(readerProfileProvider)
        .asData
        ?.value
        ?.dailyGoalMinutes;

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: sessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              _Message(text: l10n.readingTimeLoadFailed('$error')),
          data: (sessionList) {
            if (plansAsync.hasError) {
              return _Message(
                text: l10n.readingTimeLoadFailed('${plansAsync.error}'),
              );
            }
            if (!plansAsync.hasValue) {
              return const Center(child: CircularProgressIndicator());
            }
            final plans = [
              for (final plan in plansAsync.requireValue)
                MonthPlanVersion(
                  effectiveAt: plan.effectiveAt,
                  dailyGoalMinutes: plan.dailyGoalMinutes,
                  routineHour: plan.routineHour,
                  weekdays: monthPlanWeekdays(plan.routineDays),
                ),
            ];
            final now = DateTime.now();
            final books = ref.watch(booksProvider).asData?.value;
            final quotes = ref.watch(savedQuotesProvider).asData?.value;
            final reports = books == null
                ? const <BookReadingReport>[]
                : bookReadingReports(
                    books: books,
                    sessions: sessionList,
                    now: now,
                    quoteBookIds: [
                      if (quotes != null)
                        for (final quote in quotes) quote.bookId,
                    ],
                  );
            final report = reports.isEmpty ? null : reports.first;
            return _HabitLog(
              title: l10n.time,
              days: weeklyReading(sessions: sessionList, now: now),
              goalSeconds: goalMinutes == null ? null : goalMinutes * 60,
              today: now,
              sessions: sessionList,
              plans: plans,
              report: report,
              onRead: report == null
                  ? null
                  : () => context.push(
                      readingRoute(report.book.id, readingSourceLibrary),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _HabitLog extends StatefulWidget {
  const _HabitLog({
    required this.title,
    required this.days,
    required this.goalSeconds,
    required this.today,
    required this.sessions,
    required this.plans,
    required this.report,
    required this.onRead,
  });

  final String title;
  final List<DailyReading> days;
  final int? goalSeconds;
  final DateTime today;
  final List<ReadingSession> sessions;
  final List<MonthPlanVersion> plans;
  final BookReadingReport? report;
  final VoidCallback? onRead;

  @override
  State<_HabitLog> createState() => _HabitLogState();
}

class _HabitLogState extends State<_HabitLog> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.today;
  }

  void _select(DateTime day) {
    final current = _selected.toLocal();
    final next = day.toLocal();
    if (current.year == next.year &&
        current.month == next.month &&
        current.day == next.day) {
      return;
    }
    setState(() => _selected = day);
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final onRead = widget.onRead;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ScheduleHeader(title: widget.title),
        const ScheduleRule(),
        WeeklyReadingChart(
          days: widget.days,
          goalSeconds: widget.goalSeconds,
          today: widget.today,
          selectedDay: _selected,
          onDaySelected: _select,
        ),
        const ScheduleRule(),
        ReadingCalendar(
          sessions: widget.sessions,
          plans: widget.plans,
          today: widget.today,
          selectedDate: _selected,
          onDaySelected: _select,
        ),
        if (report != null && onRead != null)
          BookReadingBlock(report: report, logRow: true, onRead: onRead),
      ],
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
