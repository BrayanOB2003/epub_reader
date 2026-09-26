import 'dart:io';

import 'package:drift/native.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a reading session stays with its book and updates in place', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final started = DateTime.utc(2026, 9, 26, 12);
    final first = await _book(database, 'Uno');
    final second = await _book(database, 'Dos');

    final sessionId = await repository.insertReadingSession(
      bookId: first,
      startedAt: started,
      endedAt: started.add(const Duration(minutes: 4)),
      engagedSeconds: 240,
    );
    await repository.updateReadingSession(
      id: sessionId,
      endedAt: started.add(const Duration(minutes: 9)),
      engagedSeconds: 540,
    );

    final sessions = await database.select(database.readingSessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.bookId, first);
    expect(sessions.single.engagedSeconds, 540);
    expect(sessions.single.startedAt.toUtc(), started);
    expect(sessions.where((session) => session.bookId == second), isEmpty);
  });

  test('deleting a book removes its reading sessions', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BookRepository(
      database,
      documentsDirectory: () async => Directory.systemTemp,
    );
    final id = await _book(database, 'Uno');
    await repository.insertReadingSession(
      bookId: id,
      startedAt: DateTime.utc(2026, 9, 26, 12),
      endedAt: DateTime.utc(2026, 9, 26, 12, 10),
      engagedSeconds: 600,
    );

    final book = await repository.getBook(id);
    await repository.delete(book!);

    expect(await database.select(database.readingSessions).get(), isEmpty);
    expect(await database.select(database.books).get(), isEmpty);
  });
}

Future<int> _book(AppDatabase database, String title) {
  return database
      .into(database.books)
      .insert(
        BooksCompanion.insert(
          title: title,
          filePath: 'books/$title.epub',
          addedAt: DateTime.utc(2026, 9, 26),
        ),
      );
}
