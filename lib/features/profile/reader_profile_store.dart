import 'package:drift/drift.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readerProfileStoreProvider = Provider<ReaderProfileStore>((ref) {
  return ReaderProfileStore(ref.watch(databaseProvider));
});

final readerProfileProvider = StreamProvider<ReaderProfile?>((ref) {
  return ref.watch(readerProfileStoreProvider).watch();
});

class ReaderProfileStore {
  ReaderProfileStore(this._database);

  final AppDatabase _database;

  Stream<ReaderProfile?> watch() {
    final query = _database.select(_database.readerProfiles);
    return query.watch().map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<bool> exists() async {
    final existing = await _database.select(_database.readerProfiles).get();
    return existing.isNotEmpty;
  }

  Future<void> save({
    required String motivations,
    required int dailyGoalMinutes,
    required String routine,
  }) async {
    if (!readingGoalMinutes.contains(dailyGoalMinutes)) {
      throw ArgumentError.value(
        dailyGoalMinutes,
        'dailyGoalMinutes',
        'La meta no es una de las opciones.',
      );
    }
    await _database.delete(_database.readerProfiles).go();
    await _database
        .into(_database.readerProfiles)
        .insert(
          ReaderProfilesCompanion.insert(
            motivations: motivations,
            dailyGoalMinutes: dailyGoalMinutes,
            routine: routine,
            completedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> updateDailyGoal(int minutes) {
    if (!readingGoalMinutes.contains(minutes)) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'La meta no es una de las opciones.',
      );
    }
    return _database
        .update(_database.readerProfiles)
        .write(ReaderProfilesCompanion(dailyGoalMinutes: Value(minutes)));
  }
}
