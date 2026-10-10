import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/reader/quote_highlight.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Color stamped on the next saved quote. Quotes already saved keep theirs.
class QuoteHighlightDefaultTile extends ConsumerWidget {
  const QuoteHighlightDefaultTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selectedId =
        ref.watch(quoteHighlightDefaultProvider).asData?.value ??
        quoteHighlightDefaultId;
    return ListTile(
      title: Text(l10n.quoteHighlightDefault),
      subtitle: Text(l10n.quoteHighlightDefaultSubtitle),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: quoteHighlightById(selectedId).tint(dark: dark),
          shape: BoxShape.circle,
          border: Border.all(color: colors.rule),
        ),
        child: const SizedBox(width: 24, height: 24),
      ),
      onTap: () => _pick(context, ref, selectedId: selectedId, dark: dark),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref, {
    required String selectedId,
    required bool dark,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).quoteHighlightFailed;
    final choice = await showQuoteHighlightColors(
      context,
      selectedId: selectedId,
      dark: dark,
    );
    if (choice is! QuoteHighlightRecolor) return;
    try {
      await ref.read(quoteHighlightColorStoreProvider).write(choice.colorId);
      ref.invalidate(quoteHighlightDefaultProvider);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}
