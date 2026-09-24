import 'package:epub_reader/features/reader/reader_gestures.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
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

  test('light and dark themes set text colors only for reflowable books', () {
    final light = readerPreferences(dark: false, scroll: false, fixedLayout: false);
    final dark = readerPreferences(dark: true, scroll: true, fixedLayout: false);
    final fixed = readerPreferences(dark: true, scroll: true, fixedLayout: true);

    expect(light.publisherStyles, isFalse);
    expect(light.backgroundColor, readerLightBackground);
    expect(light.textColor, readerLightText);
    expect(light.scroll, isFalse);

    expect(dark.backgroundColor, readerDarkBackground);
    expect(dark.textColor, readerDarkText);
    expect(dark.scroll, isTrue);

    expect(fixed.scroll, isFalse);
    expect(fixed.textColor, isNull);
    expect(fixed.backgroundColor, isNull);
    expect(fixed.publisherStyles, isNull);
  });

  test('a fixed-layout publication is detected from metadata or its resources', () {
    expect(
      publicationIsFixed(
        Publication(
          metadata: Metadata(localizedTitle: LocalizedString.fromString('Cómic'), layout: 'fixed'),
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
          metadata: Metadata(localizedTitle: LocalizedString.fromString('Novela')),
          readingOrder: const [Link(href: 'c1.xhtml', properties: Properties(layout: EpubLayout.fixed))],
        ),
      ),
      isTrue,
    );
    expect(
      publicationIsFixed(Publication(metadata: Metadata(localizedTitle: LocalizedString.fromString('Novela')))),
      isFalse,
    );
  });
}
