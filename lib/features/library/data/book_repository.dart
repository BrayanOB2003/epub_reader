import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/sample_reading.dart';
import 'package:epub_reader/features/library/data/book_paths.dart';
import 'package:path_provider/path_provider.dart';

class BookRepository {
  BookRepository(
    this._database, {
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final AppDatabase _database;
  final Future<Directory> Function() _documentsDirectory;
  Directory? _documents;

  Stream<List<ReadingSession>> watchReadingSessions() {
    final query = _database.select(_database.readingSessions)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.endedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<Book>> watchBooks() {
    final query = _database.select(_database.books)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.addedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().asyncMap(_presentAll);
  }

  Future<Book?> getBook(int id) async {
    final query = _database.select(_database.books)
      ..where((table) => table.id.equals(id));
    final book = await query.getSingleOrNull();
    if (book == null) return null;
    return _present(book);
  }

  Future<List<Book>> booksWithoutHash() async {
    final query = _database.select(_database.books)
      ..where((table) => table.contentHash.isNull());
    return _presentAll(await query.get());
  }

  Future<void> saveIdentity({
    required int id,
    required String contentHash,
    String? bookUid,
  }) {
    return (_database.update(
      _database.books,
    )..where((table) => table.id.equals(id))).write(
      BooksCompanion(
        contentHash: Value(contentHash),
        bookUid: bookUid == null ? const Value.absent() : Value(bookUid),
      ),
    );
  }

  Future<Book?> findByBookUid(String bookUid) async {
    final query = _database.select(_database.books)
      ..where((table) => table.bookUid.equals(bookUid));
    final book = await query.getSingleOrNull();
    if (book == null) return null;
    return _present(book);
  }

  Future<Book?> findDuplicate({
    required String contentHash,
    String? bookUid,
  }) async {
    final byHash = _database.select(_database.books)
      ..where((table) => table.contentHash.equals(contentHash));
    final hashed = await byHash.getSingleOrNull();
    if (hashed != null) return _present(hashed);
    if (bookUid == null || bookUid.isEmpty) return null;

    final byUid = _database.select(_database.books)
      ..where((table) => table.bookUid.equals(bookUid));
    final book = await byUid.getSingleOrNull();
    if (book == null) return null;
    return _present(book);
  }

  Future<int> insert({
    required String title,
    required String filePath,
    required String contentHash,
    String? author,
    String? bookUid,
    String? coverPath,
    Uint8List? coverBytes,
  }) {
    return _database
        .into(_database.books)
        .insert(
          BooksCompanion.insert(
            title: title,
            author: Value(author),
            filePath: filePath,
            coverPath: Value(coverPath),
            coverBytes: Value(coverBytes),
            contentHash: Value(contentHash),
            bookUid: Value(bookUid),
            addedAt: DateTime.now(),
          ),
        );
  }

  Future<void> saveCover({
    required int id,
    required Uint8List coverBytes,
    String? coverPath,
  }) {
    return (_database.update(
      _database.books,
    )..where((table) => table.id.equals(id))).write(
      BooksCompanion(
        coverBytes: Value(coverBytes),
        coverPath: Value(coverPath),
      ),
    );
  }

  Future<void> saveProgress({
    required int id,
    required String locatorJson,
    required double progress,
  }) {
    return (_database.update(
      _database.books,
    )..where((table) => table.id.equals(id))).write(
      BooksCompanion(
        locatorJson: Value(locatorJson),
        progress: Value(progress.clamp(0, 1)),
      ),
    );
  }

  Future<void> saveReadingSettings({
    required int id,
    required bool darkMode,
    required bool scrollMode,
    required double fontSize,
  }) {
    return (_database.update(
      _database.books,
    )..where((table) => table.id.equals(id))).write(
      BooksCompanion(
        darkMode: Value(darkMode),
        scrollMode: Value(scrollMode),
        fontSize: Value(fontSize),
      ),
    );
  }

  Future<int> addSampleReadings({DateTime? now, Random? random}) async {
    final source = random ?? Random();
    final moment = now ?? DateTime.now();
    final books = await _database.select(_database.books).get();
    final bookIds = [for (final book in books) book.id];
    if (bookIds.isEmpty) {
      bookIds.add(
        await _database
            .into(_database.books)
            .insert(
              BooksCompanion.insert(
                title: 'Lectura de ejemplo',
                filePath: 'sample/lectura-de-ejemplo.epub',
                addedAt: moment.toUtc(),
              ),
            ),
      );
    }
    final readings = sampleReadings(now: moment, random: source);
    await _database.transaction(() async {
      for (var index = 0; index < readings.length; index++) {
        final reading = readings[index];
        await insertReadingSession(
          bookId: bookIds[index % bookIds.length],
          startedAt: reading.startedAt,
          endedAt: reading.endedAt,
          engagedSeconds: reading.engagedSeconds,
        );
      }
    });
    return readings.length;
  }

  Future<int> insertReadingSession({
    required int bookId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int engagedSeconds,
  }) {
    return _database
        .into(_database.readingSessions)
        .insert(
          ReadingSessionsCompanion.insert(
            bookId: bookId,
            startedAt: startedAt,
            endedAt: endedAt,
            engagedSeconds: engagedSeconds,
          ),
        );
  }

  Future<void> updateReadingSession({
    required int id,
    required DateTime endedAt,
    required int engagedSeconds,
  }) {
    return (_database.update(
      _database.readingSessions,
    )..where((table) => table.id.equals(id))).write(
      ReadingSessionsCompanion(
        endedAt: Value(endedAt),
        engagedSeconds: Value(engagedSeconds),
      ),
    );
  }

  Future<void> delete(Book book) async {
    await (_database.delete(
      _database.readingSessions,
    )..where((table) => table.bookId.equals(book.id))).go();
    await (_database.delete(
      _database.books,
    )..where((table) => table.id.equals(book.id))).go();
    await _deleteFile(await _deletable(book.filePath));
    final coverPath = book.coverPath;
    if (coverPath != null) await _deleteFile(await _deletable(coverPath));
  }

  Future<List<Book>> _presentAll(List<Book> books) async {
    if (books.isEmpty) return books;
    final presented = <Book>[];
    for (final book in books) {
      presented.add(await _present(book));
    }
    return presented;
  }

  Future<Book> _present(Book book) async {
    final documents = await _documentsDir();
    if (documents == null) return book;

    final portableFile = portableBookPath(book.filePath, documents.path);
    final portableCover = book.coverPath == null
        ? null
        : portableBookPath(book.coverPath!, documents.path);
    if (portableFile != book.filePath || portableCover != book.coverPath) {
      await (_database.update(
        _database.books,
      )..where((table) => table.id.equals(book.id))).write(
        BooksCompanion(
          filePath: Value(portableFile),
          coverPath: Value(portableCover),
        ),
      );
    }

    return book.copyWith(
      filePath: absoluteBookPath(portableFile, documents.path),
      coverPath: Value(
        portableCover == null
            ? null
            : absoluteBookPath(portableCover, documents.path),
      ),
    );
  }

  Future<String> _deletable(String stored) async {
    final documents = await _documentsDir();
    if (documents == null) return stored;
    return absoluteBookPath(
      portableBookPath(stored, documents.path),
      documents.path,
    );
  }

  Future<Directory?> _documentsDir() async {
    final cached = _documents;
    if (cached != null) return cached;
    try {
      final directory = await _documentsDirectory();
      return _documents = directory;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
