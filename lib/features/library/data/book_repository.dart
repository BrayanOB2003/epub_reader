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

  Future<int> insert({
    required String title,
    required String filePath,
    String? author,
    String? coverPath,
  }) {
    return _database.into(_database.books).insert(
      BooksCompanion.insert(
        title: title,
        author: Value(author),
        filePath: filePath,
        coverPath: Value(coverPath),
        addedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveProgress({required int id, required String locatorJson, required double progress}) {
    return (_database.update(_database.books)..where((table) => table.id.equals(id))).write(
      BooksCompanion(locatorJson: Value(locatorJson), progress: Value(progress.clamp(0, 1))),
    );
  }
}
