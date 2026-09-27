import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/habits/reading_calendar.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/habits/weekly_reading_chart.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingTimePage extends ConsumerWidget {
  const ReadingTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    final sessions = ref.watch(readingSessionsProvider);
    final goalMinutes = ref
        .watch(readerProfileProvider)
        .asData
        ?.value
        ?.dailyGoalMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Tiempo')),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            _Message(text: 'No se pudieron cargar los libros.\n$error'),
        data: (bookList) => sessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              _Message(text: 'No se pudo cargar el tiempo de lectura.\n$error'),
          data: (sessionList) {
            final records = readingTimeByBook(
              titles: {for (final book in bookList) book.id: book.title},
              sessions: sessionList,
            );
            final now = DateTime.now();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
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
                if (records.isEmpty)
                  const _EmptyTime()
                else
                  for (final record in records) ...[
                    const SizedBox(height: 12),
                    _BookTimeCard(record: record),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyTime extends StatelessWidget {
  const _EmptyTime();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      child: Column(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('Todavía no hay registros', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'El tiempo se guarda cuando una lectura pasa de 30 segundos.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
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

class _BookTimeCard extends StatelessWidget {
  const _BookTimeCard({required this.record});

  final BookReadingTime record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(record.title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: 12),
                Text(
                  formatReadingDuration(record.engagedSeconds),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final session in record.sessions) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatReadingMoment(session.endedAt, now: now),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    formatReadingDuration(session.engagedSeconds),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
