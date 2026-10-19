import 'dart:convert';
import 'dart:io';

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const quoteHighlightGroup = 'saved-quotes';
const quoteHighlightDefaultId = 'amber';

/// Readium paints highlights as an opaque fill behind the text and drops any
/// alpha in the tint, so each color has a pale variant for the light page and
/// a deep one for the dark page that keep the reader's text legible.
class QuoteHighlightColor {
  const QuoteHighlightColor(this.id, {required this.light, required this.dark});

  final String id;
  final Color light;
  final Color dark;

  Color tint({required bool dark}) => dark ? this.dark : light;
}

const quoteHighlightColors = <QuoteHighlightColor>[
  QuoteHighlightColor(
    'amber',
    light: Color(0xFFF6D98A),
    dark: Color(0xFF6B4E12),
  ),
  QuoteHighlightColor(
    'green',
    light: Color(0xFFCFE3B4),
    dark: Color(0xFF34502E),
  ),
  QuoteHighlightColor(
    'blue',
    light: Color(0xFFC6D8F2),
    dark: Color(0xFF2A3F66),
  ),
  QuoteHighlightColor(
    'rose',
    light: Color(0xFFF2C9D2),
    dark: Color(0xFF5E2E3B),
  ),
  QuoteHighlightColor(
    'violet',
    light: Color(0xFFDCD0F0),
    dark: Color(0xFF43365F),
  ),
];

QuoteHighlightColor quoteHighlightById(String? id) {
  for (final color in quoteHighlightColors) {
    if (color.id == id) return color;
  }
  return quoteHighlightColors.first;
}

class QuoteHighlightMark {
  const QuoteHighlightMark({
    required this.id,
    required this.locatorJson,
    this.colorId,
  });

  final int id;
  final String locatorJson;
  final String? colorId;
}

List<ReaderDecoration> quoteHighlightDecorations({
  required List<QuoteHighlightMark> quotes,
  required bool dark,
  int? activeQuoteId,
}) {
  final decorations = <ReaderDecoration>[];
  for (final quote in quotes) {
    final locator = quoteHighlightLocator(quote.locatorJson);
    if (locator == null) continue;
    final color = quoteHighlightById(quote.colorId ?? quoteHighlightDefaultId);
    decorations.add(
      ReaderDecoration(
        id: '${quote.id}',
        locator: locator,
        style: ReaderDecorationStyle(
          style: DecorationStyle.highlight,
          tint: color.tint(dark: dark),
          isActive: quote.id == activeQuoteId,
        ),
      ),
    );
  }
  return decorations;
}

Locator? quoteHighlightLocator(String raw) {
  if (raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Locator.fromJson(Map<String, dynamic>.from(decoded));
  } catch (_) {
    return null;
  }
}

class QuoteHighlightColorStore {
  QuoteHighlightColorStore({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<String> read() async {
    final file = await _file();
    if (!file.existsSync()) return quoteHighlightDefaultId;
    try {
      return quoteHighlightById(await file.readAsString()).id;
    } catch (_) {
      return quoteHighlightDefaultId;
    }
  }

  Future<void> write(String colorId) async {
    final file = await _file();
    await file.writeAsString(quoteHighlightById(colorId).id, flush: true);
  }

  Future<File> _file() async {
    final docs = await _documentsDirectory();
    return File(p.join(docs.path, 'quote_highlight_color.txt'));
  }
}

sealed class QuoteHighlightChoice {
  const QuoteHighlightChoice();
}

class QuoteHighlightRecolor extends QuoteHighlightChoice {
  const QuoteHighlightRecolor(this.colorId);

  final String colorId;
}

class QuoteHighlightDelete extends QuoteHighlightChoice {
  const QuoteHighlightDelete();
}

Future<QuoteHighlightChoice?> showQuoteHighlightColors(
  BuildContext context, {
  required String selectedId,
  required bool dark,
  bool allowDelete = false,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<QuoteHighlightChoice>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.quoteHighlightColor),
        content: Row(
          children: [
            for (final color in quoteHighlightColors)
              Expanded(
                child: _HighlightSwatch(
                  color: color.tint(dark: dark),
                  label: quoteHighlightLabel(l10n, color.id),
                  selected: color.id == selectedId,
                  onTap: () =>
                      Navigator.pop(context, QuoteHighlightRecolor(color.id)),
                ),
              ),
          ],
        ),
        actions: [
          if (allowDelete)
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, const QuoteHighlightDelete()),
              child: Text(l10n.deleteQuote),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      );
    },
  );
}

/// The color becomes the default for the next saved quote even when the
/// quote already had it.
Future<void> recolorQuoteHighlight({
  required BookRepository repository,
  required QuoteHighlightColorStore store,
  required int quoteId,
  required String? currentColorId,
  required String colorId,
}) async {
  await store.write(colorId);
  if (colorId == currentColorId) return;
  await repository.setQuoteHighlightColor(id: quoteId, colorId: colorId);
}

class _HighlightSwatch extends StatelessWidget {
  const _HighlightSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.station : colors.rule,
                  width: selected ? 3 : 1,
                ),
              ),
              child: const SizedBox(width: 28, height: 28),
            ),
          ),
        ),
      ),
    );
  }
}

String quoteHighlightLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'green' => l10n.quoteHighlightGreen,
    'blue' => l10n.quoteHighlightBlue,
    'rose' => l10n.quoteHighlightRose,
    'violet' => l10n.quoteHighlightViolet,
    _ => l10n.quoteHighlightAmber,
  };
}
