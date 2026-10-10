import 'dart:io';

import 'package:drift/native.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/quotes/quote_contrast.dart';
import 'package:epub_reader/features/reader/quote_highlight.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _locator = '{"href":"/c1.xhtml","type":"application/xhtml+xml"}';

void main() {
  test('a quote keeps the color it was saved with', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final bookId = await database
        .into(database.books)
        .insert(
          BooksCompanion.insert(
            title: 'Uno',
            filePath: 'books/uno.epub',
            addedAt: DateTime.utc(2026, 10, 10),
          ),
        );

    final blue = await repository.saveQuote(
      bookId: bookId,
      text: 'Azul',
      locatorJson: _locator,
      savedAt: DateTime.utc(2026, 10, 10, 1),
      highlightColor: 'blue',
    );
    final unmarked = await repository.saveQuote(
      bookId: bookId,
      text: 'Sin color',
      locatorJson: _locator,
      savedAt: DateTime.utc(2026, 10, 10, 2),
    );

    expect((await repository.quoteById(blue))?.highlightColor, 'blue');
    expect((await repository.quoteById(unmarked))?.highlightColor, isNull);

    await repository.setQuoteHighlightColor(id: blue, colorId: 'rose');
    expect((await repository.quoteById(blue))?.highlightColor, 'rose');
    expect((await repository.quoteById(unmarked))?.highlightColor, isNull);

    final marks = await repository.quotesForBook(bookId);
    expect(marks.map((quote) => quote.highlightColor), ['rose', null]);
  });

  test('missing color stays amber and a broken locator is skipped', () {
    final decorations = quoteHighlightDecorations(
      quotes: const [
        QuoteHighlightMark(id: 4, locatorJson: _locator),
        QuoteHighlightMark(id: 5, locatorJson: _locator, colorId: 'blue'),
        QuoteHighlightMark(id: 6, locatorJson: 'no es un localizador'),
      ],
      dark: false,
      activeQuoteId: 4,
    );

    expect(decorations, hasLength(2));
    expect(decorations.first.id, '4');
    expect(decorations.first.style.tint, quoteHighlightById('amber').light);
    expect(decorations.first.style.isActive, isTrue);
    expect(decorations.last.style.tint, quoteHighlightById('blue').light);
    expect(decorations.last.style.isActive, isFalse);
  });

  test('the dark page gets the deep variant of each color', () {
    final decorations = quoteHighlightDecorations(
      quotes: const [
        QuoteHighlightMark(id: 4, locatorJson: _locator, colorId: 'rose'),
      ],
      dark: true,
    );
    expect(decorations.single.style.tint, quoteHighlightById('rose').dark);
  });

  test('reader text stays legible on every highlight', () {
    double ratio(Color fill, Color text) =>
        contrastRatio(fill.computeLuminance(), text.computeLuminance());
    for (final color in quoteHighlightColors) {
      expect(
        ratio(color.light, readerLightText),
        greaterThanOrEqualTo(4.5),
        reason: '${color.id} light',
      );
      expect(
        ratio(color.dark, readerDarkText),
        greaterThanOrEqualTo(4.5),
        reason: '${color.id} dark',
      );
    }
  });

  test('the last chosen color becomes the next default', () async {
    final directory = await Directory.systemTemp.createTemp('highlights');
    addTearDown(() => directory.delete(recursive: true));
    final store = QuoteHighlightColorStore(
      documentsDirectory: () async => directory,
    );

    expect(await store.read(), quoteHighlightDefaultId);
    await store.write('violet');
    expect(await store.read(), 'violet');
    await store.write('desconocido');
    expect(await store.read(), quoteHighlightDefaultId);
  });

  testWidgets('tapping a swatch returns that color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: scheduleTheme(Brightness.light),
        home: const _ColorPickerHost(),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Color del resaltado'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Verde'));
    await tester.pumpAndSettle();
    expect(find.text('green'), findsOneWidget);
  });
}

class _ColorPickerHost extends StatefulWidget {
  const _ColorPickerHost();

  @override
  State<_ColorPickerHost> createState() => _ColorPickerHostState();
}

class _ColorPickerHostState extends State<_ColorPickerHost> {
  var _chosen = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(_chosen),
          TextButton(
            onPressed: () async {
              final chosen = await showQuoteHighlightColors(
                context,
                selectedId: 'amber',
                dark: false,
              );
              if (!mounted) return;
              setState(() => _chosen = chosen ?? 'nada');
            },
            child: const Text('abrir'),
          ),
        ],
      ),
    );
  }
}
