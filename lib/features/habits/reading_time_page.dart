import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/habits/reading_calendar.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/habits/weekly_reading_chart.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingTimePage extends ConsumerWidget {
  const ReadingTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(readingSessionsProvider);
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
            final now = DateTime.now();
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
                  goalSeconds: goalMinutes == null ? null : goalMinutes * 60,
                  today: now,
                ),
              ],
            );
          },
        ),
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
