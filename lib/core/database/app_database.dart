import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get author => text().nullable()();

  TextColumn get filePath => text()();

  TextColumn get coverPath => text().nullable()();

  BlobColumn get coverBytes => blob().nullable()();

  TextColumn get contentHash => text().nullable().unique()();

  TextColumn get bookUid => text().nullable()();

  TextColumn get locatorJson => text().nullable()();

  RealColumn get progress => real().withDefault(const Constant(0))();

  DateTimeColumn get addedAt => dateTime()();
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(books, books.coverBytes);
          await migrator.addColumn(books, books.contentHash);
          await migrator.addColumn(books, books.bookUid);
        }
      },
    );
  }

  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'epub_reader.sqlite'));
      return NativeDatabase(file);
    });
  }
}
