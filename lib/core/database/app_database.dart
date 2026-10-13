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

  /// True after the reader turns notifications on, or for a profile saved
  /// before this prompt existed. A skip leaves this false.
  BoolColumn get notificationsPrompted =>
      boolean().withDefault(const Constant(true))();

  /// Local calendar day (yyyy-MM-dd) of the last "not now".
  TextColumn get notificationPromptSkippedOn => text().nullable()();

  /// Reader asked Liora to silence the phone while the app is open.
  BoolColumn get focusMode => boolean().withDefault(const Constant(false))();
}

class SavedQuotes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().references(Books, #id)();

  TextColumn get passage => text()();

  TextColumn get locatorJson => text()();

  DateTimeColumn get savedAt => dateTime()();

  /// Palette id of this quote's highlight. Null uses the original default.
  TextColumn get highlightColor => text().nullable()();
}

class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().references(Books, #id)();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime()();

  IntColumn get engagedSeconds => integer()();
}

/// One row each time the goal, the days, or the hour actually change.
class ReadingPlanVersions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dailyGoalMinutes => integer()();

  IntColumn get routineHour => integer().nullable()();

  TextColumn get routineDays => text()();

  DateTimeColumn get effectiveAt => dateTime()();
}

/// A closed month, written once. [document] holds the frozen facts.
class MonthReports extends Table {
  IntColumn get year => integer()();

  IntColumn get month => integer()();

  TextColumn get document => text()();

  @override
  Set<Column> get primaryKey => {year, month};
}

@DriftDatabase(
  tables: [
    Books,
    ReadingSessions,
    ReaderProfiles,
    SavedQuotes,
    ReadingPlanVersions,
    MonthReports,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 13;

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
        if (from < 9) {
          await migrator.addColumn(
            readerProfiles,
            readerProfiles.notificationPromptSkippedOn,
          );
        }
        if (from < 10) {
          await migrator.addColumn(readerProfiles, readerProfiles.focusMode);
        }
        if (from < 11) {
          await migrator.createTable(savedQuotes);
        }
        if (from < 12) {
          await migrator.addColumn(savedQuotes, savedQuotes.highlightColor);
        }
        if (from < 13) {
          await migrator.createTable(readingPlanVersions);
          await migrator.createTable(monthReports);
          await seedPlanHistory();
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

  /// The plan saved before this archive existed counts for every past month.
  /// Later saves append their own version and do not replace this one.
  Future<void> seedPlanHistory() async {
    final existing = await select(readingPlanVersions).get();
    if (existing.isNotEmpty) return;
    final profiles = await select(readerProfiles).get();
    if (profiles.isEmpty) return;
    final saved = profiles.first;
    await into(readingPlanVersions).insert(
      ReadingPlanVersionsCompanion.insert(
        dailyGoalMinutes: saved.dailyGoalMinutes,
        routineHour: Value(saved.routineHour),
        routineDays: saved.routineDays ?? '1,2,3,4,5,6,7',
        effectiveAt: DateTime.utc(2020, 1, 1),
      ),
    );
  }
}
