import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reading time is grouped by book, newest visit first', () {
    final older = DateTime.utc(2026, 9, 25, 15);
    final newer = DateTime.utc(2026, 9, 26, 18);
    final records = readingTimeByBook(
      titles: const {1: 'Uno', 2: 'Dos'},
      sessions: [
        _session(id: 1, bookId: 1, endedAt: older, seconds: 40),
        _session(id: 2, bookId: 2, endedAt: newer, seconds: 90),
        _session(
          id: 3,
          bookId: 1,
          endedAt: newer.subtract(const Duration(hours: 1)),
          seconds: 120,
        ),
        _session(id: 4, bookId: 9, endedAt: newer, seconds: 600),
      ],
    );

    expect(records.map((record) => record.title), ['Dos', 'Uno']);
    expect(records.last.engagedSeconds, 160);
    expect(records.last.sessions.map((session) => session.id), [3, 1]);
  });

  test('durations and moments are readable', () {
    expect(formatReadingDuration(45), '45 s');
    expect(formatReadingDuration(90), '1 min 30 s');
    expect(formatReadingDuration(3600), '1 h');
    expect(formatReadingDuration(5400), '1 h 30 min');

    final now = DateTime(2026, 9, 26, 13);
    expect(
      formatReadingMoment(DateTime(2026, 9, 26, 12, 5), now: now),
      'Hoy, 12:05',
    );
    expect(
      formatReadingMoment(DateTime(2026, 9, 25, 9, 7), now: now),
      'Ayer, 09:07',
    );
    expect(
      formatReadingMoment(DateTime(2026, 9, 1, 8, 0), now: now),
      '1 sep, 08:00',
    );
  });
}

ReadingSession _session({
  required int id,
  required int bookId,
  required DateTime endedAt,
  required int seconds,
}) {
  return ReadingSession(
    id: id,
    bookId: bookId,
    startedAt: endedAt.subtract(Duration(seconds: seconds)),
    endedAt: endedAt,
    engagedSeconds: seconds,
  );
}
