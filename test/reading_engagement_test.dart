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
