import 'package:epub_reader/features/reader/reader_gestures.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('side taps follow reading direction and the center opens the menu', () {
    expect(readerZoneAt(x: 10, width: 100, rtl: false), ReaderZone.previous);
    expect(readerZoneAt(x: 50, width: 100, rtl: false), ReaderZone.menu);
    expect(readerZoneAt(x: 90, width: 100, rtl: false), ReaderZone.next);
    expect(readerZoneAt(x: 10, width: 100, rtl: true), ReaderZone.next);
    expect(readerZoneAt(x: 90, width: 100, rtl: true), ReaderZone.previous);
  });

  test(
    'taps go to Readium while text is selected, so the page does not turn',
    () {
      expect(readerClaimsTap(textSelected: true), isFalse);
      expect(readerClaimsTap(textSelected: false), isTrue);
    },
  );

  testWidgets('a short tap hits a zone and a drag stays with the reader', (
    tester,
  ) async {
    final zones = <ReaderZone>[];
    var drags = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderGestureLayer(
          rtl: false,
          scroll: false,
          textSelected: false,
          onZone: zones.add,
          onPageDrag: () => drags++,
          onSelectionTap: () {},
        ),
      ),
    );
    final box = tester.getRect(find.byType(ReaderGestureLayer));
    await tester.tapAt(Offset(box.left + 8, box.center.dy));
    expect(zones, [ReaderZone.previous]);

    zones.clear();
    await tester.timedDragFrom(
      box.center,
      const Offset(-120, 0),
      const Duration(milliseconds: 300),
    );
    expect(zones, isEmpty);
    expect(drags, 1);
  });

  testWidgets('scrolling does not report a page drag', (tester) async {
    var drags = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderGestureLayer(
          rtl: false,
          scroll: true,
          textSelected: false,
          onZone: (_) {},
          onPageDrag: () => drags++,
          onSelectionTap: () {},
        ),
      ),
    );
    final box = tester.getRect(find.byType(ReaderGestureLayer));
    await tester.timedDragFrom(
      box.center,
      const Offset(-120, 0),
      const Duration(milliseconds: 300),
    );
    expect(drags, 0);
  });

  test('a side tap while scrolling opens the neighboring chapter', () {
    const hrefs = ['c1.xhtml', 'c2.xhtml#start', 'c3.xhtml'];
    expect(
      adjacentChapterIndex(
        hrefs: hrefs,
        currentHref: 'c2.xhtml#p4',
        forward: true,
      ),
      2,
    );
    expect(
      adjacentChapterIndex(
        hrefs: hrefs,
        currentHref: 'c2.xhtml',
        forward: false,
      ),
      0,
    );
    expect(
      adjacentChapterIndex(
        hrefs: hrefs,
        currentHref: 'c1.xhtml',
        forward: false,
      ),
      isNull,
    );
    expect(
      adjacentChapterIndex(
        hrefs: hrefs,
        currentHref: 'c3.xhtml',
        forward: true,
      ),
      isNull,
    );
    expect(
      adjacentChapterIndex(
        hrefs: hrefs,
        currentHref: 'missing.xhtml',
        forward: true,
      ),
      isNull,
    );
  });

  test('light and dark themes set text colors only for reflowable books', () {
    final light = readerPreferences(
      dark: false,
      scroll: false,
      fixedLayout: false,
    );
    final dark = readerPreferences(
      dark: true,
      scroll: true,
      fixedLayout: false,
    );
    final fixed = readerPreferences(
      dark: true,
      scroll: true,
      fixedLayout: true,
    );

    expect(light.publisherStyles, isFalse);
    expect(light.backgroundColor, readerLightBackground);
    expect(light.textColor, readerLightText);
    expect(light.scroll, isFalse);
    expect(light.fontSize, readerFontSizeDefault);

    expect(dark.backgroundColor, readerDarkBackground);
    expect(dark.textColor, readerDarkText);
    expect(dark.scroll, isTrue);

    expect(fixed.scroll, isFalse);
    expect(fixed.textColor, isNull);
    expect(fixed.backgroundColor, isNull);
    expect(fixed.publisherStyles, isNull);
    expect(fixed.fontSize, isNull);
  });

  test('font size steps between the reading limits', () {
    expect(stepReaderFontSize(1, larger: true), 1.1);
    expect(stepReaderFontSize(1, larger: false), 0.9);
    expect(
      stepReaderFontSize(readerFontSizeMin, larger: false),
      readerFontSizeMin,
    );
    expect(
      stepReaderFontSize(readerFontSizeMax, larger: true),
      readerFontSizeMax,
    );
    final chosen = readerPreferences(
      dark: false,
      scroll: false,
      fixedLayout: false,
      fontSize: 1.4,
    );
    expect(chosen.fontSize, 1.4);
  });

  test(
    'a fixed-layout publication is detected from metadata or its resources',
    () {
      expect(
        publicationIsFixed(
          Publication(
            metadata: Metadata(
              localizedTitle: LocalizedString.fromString('Cómic'),
              layout: 'fixed',
            ),
          ),
        ),
        isTrue,
      );
      expect(
        publicationIsFixed(
          Publication(
            metadata: Metadata(
              localizedTitle: LocalizedString.fromString('Novela'),
              additionalProperties: {
                'presentation': <String, dynamic>{'layout': 'fixed'},
              },
            ),
          ),
        ),
        isTrue,
      );
      expect(
        publicationIsFixed(
          Publication(
            metadata: Metadata(
              localizedTitle: LocalizedString.fromString('Novela'),
            ),
            readingOrder: const [
              Link(
                href: 'c1.xhtml',
                properties: Properties(layout: EpubLayout.fixed),
              ),
            ],
          ),
        ),
        isTrue,
      );
      expect(
        publicationIsFixed(
          Publication(
            metadata: Metadata(
              localizedTitle: LocalizedString.fromString('Novela'),
            ),
          ),
        ),
        isFalse,
      );
    },
  );
}
