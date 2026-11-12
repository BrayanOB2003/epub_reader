import 'package:epub_reader/features/habits/reading_engagement.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a steady read counts the time between page turns', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    for (var minute = 2; minute <= 20; minute += 2) {
      clock.elapsed = Duration(minutes: minute);
      engagement.onSpot(_spot(minute / 100));
    }
    engagement.close();

    expect(engagement.engaged, const Duration(minutes: 20));
    expect(engagement.shouldPersist, isTrue);
  });

  test('opening the book and leaving it there counts nothing', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    clock.elapsed = const Duration(minutes: 45);
    engagement.background();
    engagement.abandon();

    expect(engagement.engaged, Duration.zero);
    expect(engagement.shouldPersist, isFalse);
  });

  test('closing within the cap counts that page, and past the cap stops at five minutes', () {
    final briefClock = _Clock();
    final brief = _engagement(briefClock);
    brief.onSpot(_spot(0));
    briefClock.elapsed = const Duration(minutes: 3);
    brief.close();
    expect(brief.engaged, const Duration(minutes: 3));

    final longClock = _Clock();
    final long = _engagement(longClock);
    long.onSpot(_spot(0));
    longClock.elapsed = const Duration(minutes: 8);
    long.close();
    expect(long.engaged, readingSegmentCap);
  });

  test('a late page turn counts at most one cap', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    clock.elapsed = const Duration(minutes: 2);
    engagement.onSpot(_spot(0.2));
    clock.elapsed = const Duration(minutes: 32);
    engagement.onSpot(_spot(0.4));

    expect(engagement.engaged, const Duration(minutes: 7));
  });

  test('skimming counts the clock, not the number of pages', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    for (var step = 1; step <= 24; step++) {
      clock.elapsed = Duration(seconds: 5 * step);
      engagement.onSpot(_spot(step / 100));
    }

    expect(engagement.engaged, const Duration(minutes: 2));
    expect(engagement.engagedSeconds, 120);
  });

  test(
    'time in the background is left out and reading resumes from the return',
    () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(_spot(0));
      clock.elapsed = const Duration(minutes: 4);
      engagement.onSpot(_spot(0.2));
      engagement.background();
      clock.elapsed = const Duration(minutes: 24);
      engagement.resume();
      clock.elapsed = const Duration(minutes: 29);
      engagement.onSpot(_spot(0.4));

      expect(engagement.engaged, const Duration(minutes: 9));
    },
  );

  test('background before any advance does not count, and a repeat position is ignored', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    clock.elapsed = const Duration(minutes: 4);
    engagement.onSpot(_spot(0));
    engagement.background();

    expect(engagement.engaged, Duration.zero);

    clock.elapsed = const Duration(minutes: 24);
    engagement.resume();
    clock.elapsed = const Duration(minutes: 25);
    engagement.close();
    expect(engagement.engaged, const Duration(minutes: 1));
  });

  test('a preference change does not credit the open segment', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    clock.elapsed = const Duration(minutes: 2);
    engagement.preferencesChanged();
    clock.elapsed = const Duration(minutes: 3);
    engagement.onSpot(_spot(0.8));
    clock.elapsed = const Duration(minutes: 5);
    engagement.onSpot(_spot(0.9));

    expect(engagement.engaged, const Duration(minutes: 2));
  });

  test('a visit under 30 seconds is not worth storing', () {
    final clock = _Clock();
    final engagement = _engagement(clock);
    engagement.onSpot(_spot(0));
    clock.elapsed = const Duration(seconds: 20);
    engagement.close();

    expect(engagement.engaged, const Duration(seconds: 20));
    expect(engagement.shouldPersist, isFalse);
  });

  test('the same chapter position is the same spot across a fragment', () {
    const before = Locator(
      href: 'c1.xhtml#p1',
      type: 'application/xhtml+xml',
      locations: Locations(progression: 0.2, position: 4),
    );
    const after = Locator(
      href: 'c1.xhtml#p9',
      type: 'application/xhtml+xml',
      locations: Locations(progression: 0.2, position: 4),
    );
    final moved = const Locator(
      href: 'c2.xhtml',
      type: 'application/xhtml+xml',
      locations: Locations(progression: 0),
    );

    expect(
      sameReadingSpot(
        readingSpotFromLocator(before),
        readingSpotFromLocator(after),
      ),
      isTrue,
    );
    expect(
      sameReadingSpot(
        readingSpotFromLocator(before),
        readingSpotFromLocator(moved),
      ),
      isFalse,
    );
  });
  group('pace', () {
    const hrefs = ['cover.xhtml', 'toc.xhtml', 'c1.xhtml', 'c2.xhtml', 'c3.xhtml'];

    ReadingSpot at(String href, double progression) => readingSpotFromLocator(
      Locator(
        href: href,
        type: 'application/xhtml+xml',
        locations: Locations(progression: progression),
      ),
      hrefs: hrefs,
    );

    test('steady page turns set the pace', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('c1.xhtml', 0));
      clock.elapsed = const Duration(minutes: 1);
      engagement.onSpot(at('c1.xhtml', 0.5));
      clock.elapsed = const Duration(minutes: 2);
      engagement.onSpot(at('c2.xhtml', 0));

      expect(engagement.paceTime, const Duration(minutes: 2));
      expect(engagement.paceProgress, closeTo(0.2, 1e-9));
    });

    test('opening a book far along and reading on measures only the reading', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('c3.xhtml', 0.5));
      clock.elapsed = const Duration(minutes: 1);
      engagement.onSpot(at('c3.xhtml', 0.6));

      expect(engagement.paceTime, const Duration(minutes: 1));
      expect(engagement.paceProgress, closeTo(0.02, 1e-9));
    });

    test('flipping past the front matter stays out of the pace', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('cover.xhtml', 0));
      clock.elapsed = const Duration(seconds: 2);
      engagement.onSpot(at('toc.xhtml', 0));
      clock.elapsed = const Duration(seconds: 4);
      engagement.onSpot(at('c1.xhtml', 0));
      clock.elapsed = const Duration(seconds: 64);
      engagement.onSpot(at('c1.xhtml', 0.5));

      expect(engagement.engaged, const Duration(seconds: 64));
      expect(engagement.paceTime, const Duration(minutes: 1));
      expect(engagement.paceProgress, closeTo(0.1, 1e-9));
    });

    test('a jump over files, a step back, or a page left open is left out', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('toc.xhtml', 0));
      clock.elapsed = const Duration(seconds: 30);
      engagement.onSpot(at('c3.xhtml', 0));
      clock.elapsed = const Duration(seconds: 60);
      engagement.onSpot(at('c2.xhtml', 0.9));
      clock.elapsed = const Duration(minutes: 7);
      engagement.onSpot(at('c3.xhtml', 0.1));

      expect(engagement.paceTime, Duration.zero);
      expect(engagement.paceProgress, 0);
    });

    test('a move the app makes is not reading, even to the next file', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('c1.xhtml', 0.1));
      clock.elapsed = const Duration(seconds: 40);
      engagement.expectJump();
      engagement.onSpot(at('c2.xhtml', 0));
      clock.elapsed = const Duration(seconds: 80);
      engagement.onSpot(at('c2.xhtml', 0.5));

      expect(engagement.engaged, const Duration(seconds: 80));
      expect(engagement.paceTime, const Duration(seconds: 40));
      expect(engagement.paceProgress, closeTo(0.1, 1e-9));
    });

    test('a cancelled move leaves the next page turn counted', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(at('c1.xhtml', 0));
      engagement.expectJump();
      engagement.jumpCancelled();
      clock.elapsed = const Duration(seconds: 30);
      engagement.onSpot(at('c1.xhtml', 0.5));

      expect(engagement.paceTime, const Duration(seconds: 30));
    });

    test('in scroll mode short stops still count', () {
      final clock = _Clock();
      final engagement = _engagement(clock)..scroll = true;
      engagement.onSpot(at('c1.xhtml', 0));
      for (var step = 1; step <= 10; step++) {
        clock.elapsed = Duration(seconds: 2 * step);
        engagement.onSpot(at('c1.xhtml', step / 100));
      }

      expect(engagement.paceTime, const Duration(seconds: 20));
      expect(engagement.paceProgress, closeTo(0.02, 1e-9));
    });

    test('a spot without the reading order sets no pace', () {
      final clock = _Clock();
      final engagement = _engagement(clock);
      engagement.onSpot(_spot(0));
      clock.elapsed = const Duration(minutes: 1);
      engagement.onSpot(_spot(0.5));

      expect(engagement.engaged, const Duration(minutes: 1));
      expect(engagement.paceTime, Duration.zero);
    });
  });
}

ReadingEngagement _engagement(_Clock clock) {
  return ReadingEngagement(elapsed: () => clock.elapsed, now: () => clock.wall);
}

ReadingSpot _spot(double progression) {
  return ReadingSpot(
    resourceHref: 'c1.xhtml',
    progression: progression,
    position: 1,
  );
}

class _Clock {
  Duration elapsed = Duration.zero;
  DateTime wall = DateTime.utc(2026, 9, 26, 12);
}
