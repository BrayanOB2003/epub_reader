import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/reading_calendar.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:flutter/material.dart';
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

  test('the weekly chart sums the current Monday to Sunday', () {
    final now = DateTime(2026, 9, 26, 18);
    final monday = DateTime(2026, 9, 21, 8, 30);
    final days = weeklyReading(
      now: now,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: monday.toUtc(),
          endedAt: monday.toUtc(),
          seconds: 600,
        ),
        _session(
          id: 2,
          bookId: 1,
          startedAt: DateTime(2026, 9, 21, 21).toUtc(),
          endedAt: DateTime(2026, 9, 21, 21, 20).toUtc(),
          seconds: 120,
        ),
        _session(
          id: 3,
          bookId: 2,
          startedAt: DateTime(2026, 9, 20, 23).toUtc(),
          endedAt: DateTime(2026, 9, 20, 23, 10).toUtc(),
          seconds: 400,
        ),
        _session(
          id: 4,
          bookId: 1,
          startedAt: DateTime(2026, 9, 27, 9).toUtc(),
          endedAt: DateTime(2026, 9, 27, 9, 15).toUtc(),
          seconds: 90,
        ),
        _session(
          id: 5,
          bookId: 1,
          startedAt: DateTime(2026, 9, 28, 8).toUtc(),
          endedAt: DateTime(2026, 9, 28, 8, 10).toUtc(),
          seconds: 300,
        ),
      ],
    );

    expect(days.first.day, DateTime(2026, 9, 21));
    expect(days.last.day, DateTime(2026, 9, 27));
    expect(days.map((day) => day.engagedSeconds), [720, 0, 0, 0, 0, 0, 90]);
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

  test('a calendar day is solid, faint or empty against the daily goal', () {
    const goal = 10 * 60;
    expect(
      readingDayMark(engagedSeconds: 0, goalSeconds: goal),
      ReadingDayMark.none,
    );
    expect(
      readingDayMark(engagedSeconds: goal - 60, goalSeconds: goal),
      ReadingDayMark.partial,
    );
    expect(
      readingDayMark(engagedSeconds: goal, goalSeconds: goal),
      ReadingDayMark.met,
    );
    expect(
      readingDayMark(engagedSeconds: goal + 60, goalSeconds: null),
      ReadingDayMark.partial,
    );

    final month = readingMonth(
      month: DateTime(2026, 9, 27),
      goalSeconds: goal,
      sessions: [
        _session(
          id: 1,
          bookId: 1,
          startedAt: DateTime(2026, 9, 10, 20).toUtc(),
          endedAt: DateTime(2026, 9, 10, 20, 6).toUtc(),
          seconds: 6 * 60,
        ),
        _session(
          id: 2,
          bookId: 2,
          startedAt: DateTime(2026, 9, 10, 21).toUtc(),
          endedAt: DateTime(2026, 9, 10, 21, 4).toUtc(),
          seconds: 4 * 60,
        ),
        _session(
          id: 3,
          bookId: 1,
          startedAt: DateTime(2026, 9, 11, 20).toUtc(),
          endedAt: DateTime(2026, 9, 11, 20, 9).toUtc(),
          seconds: 9 * 60,
        ),
        _session(
          id: 4,
          bookId: 1,
          startedAt: DateTime(2026, 8, 31, 20).toUtc(),
          endedAt: DateTime(2026, 8, 31, 20, 15).toUtc(),
          seconds: 15 * 60,
        ),
      ],
    );

    expect(month.month, DateTime(2026, 9));
    expect(month.leadingBlanks, DateTime(2026, 9, 1).weekday - 1);
    expect(month.days, hasLength(30));
    expect(month.days[9].mark, ReadingDayMark.met);
    expect(month.days[10].mark, ReadingDayMark.partial);
    expect(month.days[11].mark, ReadingDayMark.none);
    expect(formatReadingMonth(month.month), 'Septiembre 2026');
  });

  testWidgets('the calendar stays on the current month and can move back', (
    tester,
  ) async {
    final today = DateTime(2026, 9, 27, 15);
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCalendar(
              sessions: [
                _session(
                  id: 1,
                  bookId: 1,
                  startedAt: DateTime(2026, 9, 10, 20).toUtc(),
                  endedAt: DateTime(2026, 9, 10, 20, 10).toUtc(),
                  seconds: 10 * 60,
                ),
                _session(
                  id: 2,
                  bookId: 1,
                  startedAt: DateTime(2026, 9, 11, 20).toUtc(),
                  endedAt: DateTime(2026, 9, 11, 20, 9).toUtc(),
                  seconds: 9 * 60,
                ),
              ],
              goalSeconds: 10 * 60,
              today: today,
            ),
          ),
        ),
      );

      expect(find.text('Septiembre 2026'), findsOneWidget);
      expect(
        find.bySemanticsLabel('10 de septiembre, meta cumplida'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('11 de septiembre, leído sin cumplir la meta'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('12 de septiembre, sin lectura'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_right),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.byTooltip('Mes anterior'));
      await tester.pump();
      expect(find.text('Agosto 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Mes siguiente'));
      await tester.pump();
      expect(find.text('Septiembre 2026'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}

ReadingSession _session({
  required int id,
  required int bookId,
  required DateTime endedAt,
  required int seconds,
  DateTime? startedAt,
}) {
  return ReadingSession(
    id: id,
    bookId: bookId,
    startedAt: startedAt ?? endedAt.subtract(Duration(seconds: seconds)),
    endedAt: endedAt,
    engagedSeconds: seconds,
  );
}
