import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/habits/book_reading_block.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookReadingsPage extends ConsumerWidget {
  const BookReadingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(readingSessionsProvider);
    final books = ref.watch(booksProvider);
    final quotes = ref.watch(savedQuotesProvider).asData?.value;
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
              child: sessions.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _Message(text: l10n.readingTimeLoadFailed('$error')),
                data: (sessionList) => books.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      _Message(text: l10n.readingTimeLoadFailed('$error')),
                  data: (bookList) => BookReadingList(
                    reports: bookReadingReports(
                      books: bookList,
                      sessions: sessionList,
                      now: DateTime.now(),
                      quoteBookIds: [
                        if (quotes != null)
                          for (final quote in quotes) quote.bookId,
                      ],
                    ),
                    onRead: (report) => context.push(
                      readingRoute(report.book.id, readingSourceLibrary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookReadingList extends StatelessWidget {
  const BookReadingList({
    required this.reports,
    required this.onRead,
    super.key,
  });

  final List<BookReadingReport> reports;
  final ValueChanged<BookReadingReport> onRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (reports.isEmpty) {
      return ListView(
        children: [
          ScheduleHeader(title: l10n.readingByBook),
          const ScheduleRule(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.readingByBookEmpty, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: reports.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ScheduleHeader(title: l10n.readingByBook);
        }
        final report = reports[index - 1];
        return BookReadingBlock(
          key: ValueKey(report.book.id),
          report: report,
          onRead: () => onRead(report),
        );
      },
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
