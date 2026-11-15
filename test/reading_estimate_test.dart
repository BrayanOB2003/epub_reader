import 'package:epub_reader/features/habits/reading_estimate.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the book and the chapter share one pace', () {
    final early = estimateReading(secondsPerBook: null, progress: 0.5);
    expect(early.bookMinutes, isNull);
    expect(early.chapterMinutes, isNull);

    final estimate = estimateReading(
      secondsPerBook: 40 * 60,
      progress: 0.5,
      chapterStart: 0.4,
      chapterEnd: 0.6,
    );
    expect(estimate.bookMinutes, 20);
    expect(estimate.chapterMinutes, 4);
    expect(estimate.chapterAlmostDone, isTrue);

    final longer = estimateReading(
      secondsPerBook: 40 * 60,
      progress: 0.5,
      chapterStart: 0.2,
      chapterEnd: 0.8,
    );
    expect(longer.chapterMinutes, 10);
    expect(longer.chapterAlmostDone, isFalse);
  });

  test('minutes round to the minute under 10 and to 5 after that', () {
    expect(readingMinutes(20), isNull);
    expect(readingMinutes(8 * 60), 8);
    expect(readingMinutes(12 * 60), 10);
    expect(readingMinutes(13 * 60), 15);
  });

  test('the measured pace ignores where the book was opened', () {
    // Reopened at 60 %: 10 minutes read, 4 % of the book covered.
    const tally = ReadingTally(
      engagedSeconds: 10 * 60,
      paceSeconds: 10 * 60,
      paceProgress: 0.04,
    );
    expect(tally.secondsPerBook(0.6), 250 * 60);
    expect(
      estimateReading(
        secondsPerBook: tally.secondsPerBook(0.6),
        progress: 0.6,
      ).bookMinutes,
      100,
    );
  });

  test('too little measured pace shows nothing on a new book', () {
    const tally = ReadingTally(
      engagedSeconds: 10 * 60,
      paceSeconds: 10 * 60,
      paceProgress: 0.01,
    );
    expect(tally.secondsPerBook(0.6), isNull);
  });

  test('older sessions fall back to all the time over the position', () {
    final tally = const ReadingTally().plus(engagedSeconds: 20 * 60);
    expect(tally.untracked, isTrue);
    expect(tally.secondsPerBook(0.5), 40 * 60);
    expect(tally.secondsPerBook(0.01), isNull);

    final short = const ReadingTally().plus(engagedSeconds: 90);
    expect(short.secondsPerBook(0.5), isNull);
  });

  test('once measured, the pace wins over older sessions', () {
    final tally = const ReadingTally()
        .plus(engagedSeconds: 5 * 60)
        .plus(engagedSeconds: 10 * 60, paceSeconds: 8 * 60, paceProgress: 0.04);
    expect(tally.engagedSeconds, 15 * 60);
    expect(tally.secondsPerBook(0.6), 200 * 60);
  });

  test('a chapter is the run of files between two index entries', () {
    const hrefs = ['a.xhtml', 'b.xhtml', 'c.xhtml', 'd.xhtml'];
    final span = chapterSpan(
      hrefs: hrefs,
      contents: const [
        Link(href: 'a.xhtml', title: 'Uno'),
        Link(href: 'c.xhtml', title: 'Dos'),
      ],
      href: 'b.xhtml',
    );
    expect(span?.start, 0);
    expect(span?.end, 0.5);
    expect(spineProgress(hrefs: hrefs, href: 'b.xhtml', progression: 0), 0.25);
  });

  test('several chapters in one file have no cut', () {
    final span = chapterSpan(
      hrefs: const ['a.xhtml', 'b.xhtml'],
      contents: const [
        Link(href: 'b.xhtml', title: 'Dos'),
        Link(href: 'b.xhtml#p2', title: 'Tres'),
      ],
      href: 'b.xhtml',
    );
    expect(span, isNull);
  });

  test('a part is not a second chapter on the same file', () {
    final span = chapterSpan(
      hrefs: const ['a.xhtml', 'b.xhtml'],
      contents: const [
        Link(
          href: 'a.xhtml',
          title: 'Parte',
          children: [Link(href: 'a.xhtml', title: 'Capítulo')],
        ),
      ],
      href: 'a.xhtml',
    );
    expect(span?.start, 0);
    expect(span?.end, 1);
  });

  test('without an index each file is a chapter', () {
    final span = chapterSpan(
      hrefs: const ['a.xhtml', 'b.xhtml', 'c.xhtml', 'd.xhtml'],
      contents: const [],
      href: 'b.xhtml',
    );
    expect(span?.start, 0.25);
    expect(span?.end, 0.5);
  });
}
