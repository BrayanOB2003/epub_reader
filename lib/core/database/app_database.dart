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

  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();

  BoolColumn get scrollMode => boolean().withDefault(const Constant(false))();

  RealColumn get fontSize => real().withDefault(const Constant(1))();

  DateTimeColumn get addedAt => dateTime()();
}

class ReaderProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get motivations => text()();

  IntColumn get dailyGoalMinutes => integer()();

  TextColumn get routine => text()();

  IntColumn get routineHour => integer().nullable()();

  TextColumn get routineDays => text().nullable()();

  DateTimeColumn get completedAt => dateTime()();

  /// False only for a profile saved before the notification prompt is answered.
  /// Existing rows default to true so the prompt stays tied to first onboarding.
  BoolColumn get notificationsPrompted =>
      boolean().withDefault(const Constant(true))();
}

class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().references(Books, #id)();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime()();

  IntColumn get engagedSeconds => integer()();
}

@DriftDatabase(tables: [Books, ReadingSessions, ReaderProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(books, books.coverBytes);
          await migrator.addColumn(books, books.contentHash);
          await migrator.addColumn(books, books.bookUid);
        }
        if (from < 3) {
          await migrator.addColumn(books, books.darkMode);
          await migrator.addColumn(books, books.scrollMode);
          await migrator.addColumn(books, books.fontSize);
        }
        if (from < 4) {
          await migrator.createTable(readingSessions);
        }
        if (from < 5) {
          await migrator.createTable(readerProfiles);
        }
        if (from < 6) {
          await migrator.addColumn(readerProfiles, readerProfiles.routineHour);
        }
        if (from < 7) {
          await migrator.addColumn(readerProfiles, readerProfiles.routineDays);
        }
        if (from < 8) {
          await migrator.addColumn(
            readerProfiles,
            readerProfiles.notificationsPrompted,
          );
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
