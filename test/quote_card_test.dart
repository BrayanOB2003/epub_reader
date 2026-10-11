import 'dart:io';
import 'dart:typed_data';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/profile/quotes_page.dart';
import 'package:epub_reader/features/quotes/quote_background_store.dart';
import 'package:epub_reader/features/quotes/quote_card_layout.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:epub_reader/features/quotes/quote_card_render.dart';
import 'package:epub_reader/features/quotes/quote_card_style_store.dart';
import 'package:epub_reader/features/quotes/quote_contrast.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a light photo keeps a dark ink without raising the veil', () {
    final pick = suggestQuoteInk(
      sample: QuoteBackgroundSample(32, 32, _solid(0xFFFFFF, 32, 32)),
      cardAspect: 9 / 16,
      veil: 0,
    );
    expect(pick.inkId, 'black');
    expect(pick.veil, 0);
    expect(pick.contrast, greaterThanOrEqualTo(quoteContrastFloor));
  });

  test('a dark photo keeps a light ink', () {
    final pick = suggestQuoteInk(
      sample: QuoteBackgroundSample(32, 32, _solid(0x000000, 32, 32)),
      cardAspect: 1,
      veil: 0,
    );
    expect(pick.inkId, 'white');
    expect(pick.veil, 0);
    expect(pick.contrast, greaterThanOrEqualTo(quoteContrastFloor));
  });

  test('a split photo raises the veil until the quote can be read', () {
    final pick = suggestQuoteInk(
      sample: QuoteBackgroundSample(32, 32, _split(32, 32)),
      cardAspect: 9 / 16,
      veil: 0,
    );
    expect(pick.veil, greaterThan(0));
    expect(pick.contrast, greaterThanOrEqualTo(quoteContrastFloor));
  });

  test('cover crop keeps the center of a wide photo', () {
    final crop = coverCrop(imageWidth: 200, imageHeight: 100, cardAspect: 1);
    expect(crop.left, 50);
    expect(crop.top, 0);
    expect(crop.width, 100);
    expect(crop.height, 100);
  });

  test('a short passage fits and a very long one does not', () {
    final fitted = measureQuoteCard(
      passage: 'Una línea',
      attribution: 'El libro',
      cardWidth: 1080,
      cardHeight: 1920,
      font: QuoteCardFont.plain,
      textScale: 1,
      color: const Color(0xFFFFFFFF),
    );
    expect(fitted.fits, isTrue);

    final overflow = measureQuoteCard(
      passage: List.filled(4000, 'palabra').join(' '),
      attribution: 'El libro',
      cardWidth: 1080,
      cardHeight: 1920,
      font: QuoteCardFont.plain,
      textScale: 1,
      color: const Color(0xFFFFFFFF),
    );
    expect(overflow.fits, isFalse);
    expect(overflow.passageSize, lessThan(fitted.passageSize));
  });

  test('an imported background is stored, listed, and removed', () async {
    final dir = await Directory.systemTemp.createTemp('quote-backgrounds');
    addTearDown(() => dir.delete(recursive: true));
    final store = QuoteBackgroundStore(
      documentsDirectory: () async => dir,
      prepare: (bytes) {
        if (bytes.isEmpty) return (null, 'invalid');
        if (bytes.length > 8) return (null, 'large');
        return (Uint8List.fromList([1, 2, 3]), null);
      },
    );

    await expectLater(
      store.importBytes(Uint8List(0)),
      throwsA(
        isA<QuoteBackgroundException>().having(
          (e) => e.tooLarge,
          'tooLarge',
          isFalse,
        ),
      ),
    );
    await expectLater(
      store.importBytes(Uint8List(9)),
      throwsA(
        isA<QuoteBackgroundException>().having(
          (e) => e.tooLarge,
          'tooLarge',
          isTrue,
        ),
      ),
    );

    final stored = await store.importBytes(Uint8List.fromList([4, 5, 6]));
    expect(await File(stored.path).readAsBytes(), [1, 2, 3]);
    expect((await store.list()).single.id, stored.id);
    expect(await store.load(id: stored.id, imported: true), [1, 2, 3]);

    await store.delete(stored.id);
    expect(await store.list(), isEmpty);
  });

  test('a photo is reduced so its long side stays within 2000 px', () {
    final wide = img.Image(width: 2100, height: 20);
    img.fill(wide, color: img.ColorRgb8(20, 40, 60));
    final prepared = prepareQuoteBackground(img.encodePng(wide));
    final jpeg = prepared.$1;
    expect(prepared.$2, isNull);
    final decoded = img.decodeJpg(jpeg!);
    expect(decoded!.width, lessThanOrEqualTo(quoteBackgroundMaxSide));
    expect(decoded.height, lessThanOrEqualTo(quoteBackgroundMaxSide));
    expect(decoded.width, greaterThan(decoded.height));

    final preparedInvalid = prepareQuoteBackground(
      Uint8List.fromList([1, 2, 3]),
    );
    expect(preparedInvalid.$1, isNull);
    expect(preparedInvalid.$2, 'invalid');
  });

  test('the last card style is remembered', () async {
    final dir = await Directory.systemTemp.createTemp('quote-style');
    addTearDown(() => dir.delete(recursive: true));
    final store = QuoteCardStyleStore(documentsDirectory: () async => dir);
    expect(await store.read(), QuoteCardStyle.initial);

    const style = QuoteCardStyle(
      format: QuoteCardFormat.square,
      font: QuoteCardFont.condensed,
      textScale: 1.2,
      veil: 0.24,
      inkAutomatic: false,
      inkId: 'cream',
    );
    await store.write(style);
    final read = await store.read();
    expect(read.format, QuoteCardFormat.square);
    expect(read.font, QuoteCardFont.condensed);
    expect(read.textScale, 1.2);
    expect(read.veil, 0.24);
    expect(read.inkAutomatic, isFalse);
    expect(read.inkId, 'cream');

    await File('${dir.path}/quote_card_style.json').writeAsString('{');
    expect(await store.read(), QuoteCardStyle.initial);
  });

  test('renders a png of the card', () async {
    final photo = img.Image(width: 16, height: 24);
    img.fill(photo, color: img.ColorRgb8(10, 12, 16));
    final png = await renderQuoteCard(
      background: img.encodePng(photo),
      style: QuoteCardStyle.initial,
      aspect: 9 / 16,
      passage: 'Una cita',
      attribution: 'El libro',
    );
    expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  });

  testWidgets('the image button opens the card for that quote', (tester) async {
    final router = GoRouter(
      initialLocation: '/quotes',
      routes: [
        GoRoute(path: '/quotes', builder: (_, _) => const QuotesPage()),
        GoRoute(
          path: '/quotes/:quoteId/card',
          builder: (_, state) =>
              Text('card ${state.pathParameters['quoteId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedQuotesProvider.overrideWith((ref) => Stream.value([_quote])),
        ],
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Crear imagen'));
    await tester.pumpAndSettle();
    expect(find.text('card 3'), findsOneWidget);
  });
}

ReadingQuote get _quote => ReadingQuote(
  id: 3,
  bookId: 7,
  text: 'Un pasaje',
  locatorJson: '{"href":"/c1.xhtml"}',
  savedAt: DateTime.utc(2026, 10, 10),
  bookTitle: 'Uno',
  author: 'Autora',
);

Uint8List _solid(int rgb, int width, int height) {
  final bytes = Uint8List(width * height * 4);
  final red = (rgb >> 16) & 0xFF;
  final green = (rgb >> 8) & 0xFF;
  final blue = rgb & 0xFF;
  for (var index = 0; index < bytes.length; index += 4) {
    bytes[index] = red;
    bytes[index + 1] = green;
    bytes[index + 2] = blue;
    bytes[index + 3] = 255;
  }
  return bytes;
}

Uint8List _split(int width, int height) {
  final bytes = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final index = (y * width + x) * 4;
      final channel = x < width / 2 ? 0 : 255;
      bytes[index] = channel;
      bytes[index + 1] = channel;
      bytes[index + 2] = channel;
      bytes[index + 3] = 255;
    }
  }
  return bytes;
}
