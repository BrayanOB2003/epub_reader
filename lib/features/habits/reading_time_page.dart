import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
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
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                ScheduleHeader(title: l10n.time),
                const ScheduleRule(),
                WeeklyReadingChart(
                  days: weeklyReading(sessions: sessionList, now: now),
                  goalSeconds: goalMinutes == null ? null : goalMinutes * 60,
                  today: now,
                ),
                const SizedBox(height: 12),
                ReadingCalendar(
                  sessions: sessionList,
                  plans: plans,
                  today: now,
                ),
                if (report != null)
                  BookReadingBlock(
                    report: report,
                    onRead: () => context.push(
                      readingRoute(report.book.id, readingSourceLibrary),
                    ),
                  ),
                if (reports.length > 1)
                  _AllBooks(onTap: () => context.push('/time/books')),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AllBooks extends StatelessWidget {
  const _AllBooks({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScheduleRule(),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: colors.station,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: Text(AppLocalizations.of(context).allReadingBooks),
          ),
        ),
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
