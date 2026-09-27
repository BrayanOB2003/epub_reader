import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/sample_reading.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample readings cover a month and a half in whole minutes', () {
    final now = DateTime(2026, 9, 27, 16, 5);
    final readings = sampleReadings(
      now: now,
      random: _SequenceRandom([0, 15, 7]),
    );

    expect(sampleReadingFirstDay(now), DateTime(2026, 8, 12));
    expect(readings.first.startedAt.toLocal(), DateTime(2026, 8, 12, 20));
    expect(readings.last.startedAt.toLocal(), DateTime(2026, 9, 27, 20));
    expect(readings.first.engagedSeconds, 0);
    expect(readings[1].engagedSeconds, 15 * 60);
    expect(readings[2].engagedSeconds, 7 * 60);
    expect(
      readings.every(
        (reading) =>
            reading.engagedSeconds >= 0 && reading.engagedSeconds <= 15 * 60,
      ),
      isTrue,
    );
    expect(
      readings.length,
      DateTime(2026, 9, 27).difference(DateTime(2026, 8, 12)).inDays + 1,
    );
  });

  test('sample readings are stored, and a book is created when the library is empty', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final now = DateTime(2026, 9, 27, 16);

    final count = await repository.addSampleReadings(
      now: now,
      random: _SequenceRandom([3]),
    );

    final books = await database.select(database.books).get();
    final sessions = await database.select(database.readingSessions).get();
    expect(books.single.title, 'Lectura de ejemplo');
    expect(sessions, hasLength(count));
    expect(
      sessions.every((session) => session.bookId == books.single.id),
      isTrue,
    );
    expect(sessions.every((session) => session.engagedSeconds == 180), isTrue);
    expect(
      sessions.map((session) => session.startedAt.toLocal()).toSet(),
      hasLength(count),
    );
  });
}

class _SequenceRandom implements Random {
  _SequenceRandom(this.values);

  final List<int> values;
  var _index = 0;

  @override
  int nextInt(int max) {
    final value = values[_index % values.length];
    _index += 1;
    return value % max;
  }

  @override
  bool nextBool() => nextInt(2) == 1;

  @override
  double nextDouble() => nextInt(1000) / 1000;
}
