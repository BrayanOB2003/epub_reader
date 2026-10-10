import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuotesPage extends ConsumerWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(savedQuotesProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: l10n.back,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: quotes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.quotesLoadFailed('$error'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) return const _EmptyQuotes();
                  return ListView.builder(
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScheduleHeader(title: l10n.savedQuotes),
                            const ScheduleRule(),
                          ],
                        );
                      }
                      return _QuoteTile(quote: items[index - 1]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuotes extends StatelessWidget {
  const _EmptyQuotes();

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        ScheduleHeader(title: l10n.savedQuotes),
        const ScheduleRule(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.noQuotes, style: programTitle(colors.ink, size: 36)),
              const SizedBox(height: 8),
              Text(
                l10n.noQuotesBody,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: colors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({required this.quote});

  final ReadingQuote quote;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final title = quote.bookTitle.trim();
    final bookTitle = title.isEmpty ? l10n.untitled : title;
    return Column(
      children: [
        Semantics(
          button: true,
          label: '${quote.text}, $bookTitle',
          excludeSemantics: true,
          child: InkWell(
            onTap: () =>
                context.push(quoteReadingRoute(quote.bookId, quote.id)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bookTitle,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const ScheduleRule(),
      ],
    );
  }
}
