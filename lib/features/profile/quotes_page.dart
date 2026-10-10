import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/profile/quote_groups.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
                  final entries = _entries(arrangeQuotes(items));
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return switch (entry) {
                        _QuoteHeading() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScheduleHeader(title: l10n.savedQuotes),
                            const ScheduleRule(),
                          ],
                        ),
                        _QuoteBook(:final group) => _BookHeading(group: group),
                        _QuoteLine(:final quote) => _PaperQuote(
                          key: ValueKey('quote-${quote.id}'),
                          quote: quote,
                          onDelete: () =>
                              _confirmDelete(context, ref, quote.id),
                        ),
                      };
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

sealed class _QuoteEntry {
  const _QuoteEntry();
}

class _QuoteHeading extends _QuoteEntry {
  const _QuoteHeading();
}

class _QuoteBook extends _QuoteEntry {
  const _QuoteBook(this.group);

  final QuoteBookGroup group;
}

class _QuoteLine extends _QuoteEntry {
  const _QuoteLine(this.quote);

  final ReadingQuote quote;
}

List<_QuoteEntry> _entries(List<QuoteBookGroup> groups) {
  return [
    const _QuoteHeading(),
    for (final group in groups) ...[
      _QuoteBook(group),
      for (final quote in group.quotes) _QuoteLine(quote),
    ],
  ];
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteQuoteTitle),
      content: Text(l10n.deleteQuoteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(bookRepositoryProvider).deleteQuote(id);
  } catch (_) {
    if (!context.mounted) return;
    _showMessage(context, l10n.quoteDeleteFailed);
    return;
  }
  if (!context.mounted) return;
  _showMessage(context, l10n.quoteDeleted);
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              const SizedBox(height: 24),
              ScheduleAction(
                label: l10n.library,
                onPressed: () => context.go('/library'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookHeading extends StatelessWidget {
  const _BookHeading({required this.group});

  final QuoteBookGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final author = _shownAuthor(group.author);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _shownTitle(group.bookTitle, l10n),
            style: programTitle(colors.ink, size: 22),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (author != null) ...[
            const SizedBox(height: 4),
            Text(
              author,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colors.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaperQuote extends StatelessWidget {
  const _PaperQuote({required this.quote, required this.onDelete, super.key});

  final ReadingQuote quote;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final title = _shownTitle(quote.bookTitle, l10n);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 4, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    scheduleDay(
                      quote.savedAt,
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuotePassage(
                      quote: quote,
                      bookTitle: title,
                      color: colors.ink,
                    ),
                    _QuoteActions(
                      quote: quote,
                      color: colors.muted,
                      onDelete: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ScheduleRule(),
      ],
    );
  }
}

class _QuotePassage extends StatelessWidget {
  const _QuotePassage({
    required this.quote,
    required this.bookTitle,
    required this.color,
  });

  final ReadingQuote quote;
  final String bookTitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${quote.text}, $bookTitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push(quoteReadingRoute(quote.bookId, quote.id)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              quote.text,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuoteActions extends StatelessWidget {
  const _QuoteActions({
    required this.quote,
    required this.color,
    required this.onDelete,
  });

  final ReadingQuote quote;
  final Color color;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = Theme.of(context).platform;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _QuoteIconButton(
          tooltip: l10n.createQuoteImage,
          icon: _imageIcon(platform),
          color: color,
          onPressed: (_) => context.push(quoteCardRoute(quote.id)),
        ),
        _QuoteIconButton(
          tooltip: l10n.shareQuoteText,
          icon: _shareIcon(platform),
          color: color,
          onPressed: (buttonContext) => _share(buttonContext, quote),
        ),
        _QuoteIconButton(
          tooltip: l10n.deleteQuote,
          icon: _deleteIcon(platform),
          color: color,
          onPressed: (_) => onDelete(),
        ),
      ],
    );
  }
}

class _QuoteIconButton extends StatelessWidget {
  const _QuoteIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      color: color,
      onPressed: () => onPressed(context),
      icon: Icon(icon),
    );
  }
}

IconData _imageIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? CupertinoIcons.photo
      : Icons.photo_outlined;
}

IconData _shareIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? CupertinoIcons.share
      : Icons.ios_share;
}

IconData _deleteIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? CupertinoIcons.trash
      : Icons.delete_outline;
}

Future<void> _share(BuildContext context, ReadingQuote quote) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null || !box.hasSize
      ? null
      : box.localToGlobal(Offset.zero) & box.size;
  try {
    await SharePlus.instance.share(
      ShareParams(text: quoteShareBody(quote), sharePositionOrigin: origin),
    );
  } catch (_) {
    if (!context.mounted) return;
    _showMessage(context, AppLocalizations.of(context).quoteShareFailed);
  }
}

String _shownTitle(String title, AppLocalizations l10n) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

String? _shownAuthor(String? author) {
  final trimmed = author?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return trimmed;
}
