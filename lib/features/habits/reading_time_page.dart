import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingTimePage extends ConsumerWidget {
  const ReadingTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    final sessions = ref.watch(readingSessionsProvider);

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
            if (records.isEmpty) return const _EmptyTime();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _BookTimeCard(record: records[index]),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
