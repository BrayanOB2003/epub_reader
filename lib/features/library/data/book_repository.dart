import 'package:drift/drift.dart';
import 'package:epub_reader/core/database/app_database.dart';

class BookRepository {
  BookRepository(this._database);

  final AppDatabase _database;

  Stream<List<Book>> watchBooks() {
    final query = _database.select(_database.books)
      ..orderBy([(table) => OrderingTerm(expression: table.addedAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<Book?> getBook(int id) {
    final query = _database.select(_database.books)..where((table) => table.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<Book>> booksWithoutHash() {
    final query = _database.select(_database.books)..where((table) => table.contentHash.isNull());
    return query.get();
  }

  Future<void> saveIdentity({required int id, required String contentHash, String? bookUid}) {
    return (_database.update(_database.books)..where((table) => table.id.equals(id))).write(
      BooksCompanion(
        contentHash: Value(contentHash),
        bookUid: bookUid == null ? const Value.absent() : Value(bookUid),
      ),
    );
  }

  Future<Book?> findDuplicate({required String contentHash, String? bookUid}) async {
    final byHash = _database.select(_database.books)..where((table) => table.contentHash.equals(contentHash));
    final hashed = await byHash.getSingleOrNull();
    if (hashed != null) return hashed;
    if (bookUid == null || bookUid.isEmpty) return null;

    final byUid = _database.select(_database.books)..where((table) => table.bookUid.equals(bookUid));
    return byUid.getSingleOrNull();
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
    return _database.into(_database.books).insert(
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

  Future<void> saveCover({required int id, required Uint8List coverBytes, String? coverPath}) {
    return (_database.update(_database.books)..where((table) => table.id.equals(id))).write(
      BooksCompanion(coverBytes: Value(coverBytes), coverPath: Value(coverPath)),
    );
  }

  Future<void> saveProgress({required int id, required String locatorJson, required double progress}) {
    return (_database.update(_database.books)..where((table) => table.id.equals(id))).write(
      BooksCompanion(locatorJson: Value(locatorJson), progress: Value(progress.clamp(0, 1))),
    );
  }
}
