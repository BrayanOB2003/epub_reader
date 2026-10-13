import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/month_report_document.dart';
import 'package:epub_reader/features/habits/month_report_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an existing plan is remembered from before the archive', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.readerProfiles)
        .insert(
          ReaderProfilesCompanion.insert(
            motivations: 'habit',
            dailyGoalMinutes: 10,
            routine: 'afternoon',
            routineHour: const Value(14),
            routineDays: const Value('1,2,3,4,5,6,7'),
            completedAt: DateTime.utc(2026, 9, 28),
          ),
        );

    await database.seedPlanHistory();
    await database.seedPlanHistory();
    final versions = await database.select(database.readingPlanVersions).get();

    expect(versions, hasLength(1));
    expect(versions.single.dailyGoalMinutes, 10);
    expect(versions.single.routineHour, 14);
    expect(versions.single.routineDays, '1,2,3,4,5,6,7');
    expect(
      versions.single.effectiveAt.isAtSameMomentAs(DateTime.utc(2020, 1, 1)),
      isTrue,
    );
  });

  test(
    'elapsed months close once and a later goal does not rewrite them',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final store = MonthReportStore(database);
      final plan = MonthPlanVersion(
        effectiveAt: DateTime.utc(2020, 1, 1),
        dailyGoalMinutes: 10,
        routineHour: 14,
        weekdays: defaultReadingWeekdays,
      );
      final sessions = [
        for (var day = 13; day <= 31; day++)
          _session(id: day, at: DateTime(2026, 8, day, 21)),
        for (var day = 1; day <= 30; day++)
          _session(
            id: 100 + day,
            at: DateTime(2026, 9, day, 21),
            seconds: day == 3 || day == 22 ? 9 * 60 : 10 * 60,
          ),
        _session(id: 200, at: DateTime(2026, 10, 2, 21)),
      ];

      await store.closeElapsed(
        sessions: sessions,
        books: [_book(title: 'Faro')],
        quotes: const [],
        plans: [plan],
        now: DateTime(2026, 10, 13, 12),
      );

      final first = await database.select(database.monthReports).get();
      expect(first, hasLength(2));
      final september = decodeMonthReport(
        first.firstWhere((row) => row.month == 9).document,
        month: DateTime(2026, 9),
      );
      final august = decodeMonthReport(
        first.firstWhere((row) => row.month == 8).document,
        month: DateTime(2026, 8),
      );
      expect(september.metDays, 28);
      expect(september.plannedDays, 30);
      expect(september.books.single.title, 'Faro');
      expect(august.metDays, 19);
      expect(august.plannedDays, 31);
      expect(first.any((row) => row.month == 10), isFalse);

      final septemberDocument = first
          .firstWhere((row) => row.month == 9)
          .document;
      await store.closeElapsed(
        sessions: [sessions.last],
        books: [_book(title: 'Otro')],
        quotes: const [],
        plans: [
          plan,
          MonthPlanVersion(
            effectiveAt: DateTime(2026, 10, 1),
            dailyGoalMinutes: 30,
            routineHour: 14,
            weekdays: defaultReadingWeekdays,
          ),
        ],
        now: DateTime(2026, 10, 13, 12),
      );

      final second = await database.select(database.monthReports).get();
      expect(second, hasLength(2));
      final kept = second.firstWhere((row) => row.month == 9);
      expect(kept.document, septemberDocument);
      expect(
        decodeMonthReport(kept.document, month: DateTime(2026, 9)).metDays,
        28,
      );
      expect(
        decodeMonthReport(
          kept.document,
          month: DateTime(2026, 9),
        ).books.single.title,
        'Faro',
      );
    },
  );
}

ReadingSession _session({
  required int id,
  required DateTime at,
  int seconds = 10 * 60,
}) {
  return ReadingSession(
    id: id,
    bookId: 1,
    startedAt: at,
    endedAt: at.add(Duration(seconds: seconds)),
    engagedSeconds: seconds,
  );
}

Book _book({required String title}) {
  return Book(
    id: 1,
    title: title,
    filePath: 'book.epub',
    progress: 0.4,
    darkMode: false,
    scrollMode: false,
    fontSize: 1,
    addedAt: DateTime(2026, 1, 1),
  );
}
