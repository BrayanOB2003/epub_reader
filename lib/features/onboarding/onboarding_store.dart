import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';

class OnboardingStore {
  OnboardingStore(this._database);

  final AppDatabase _database;

  Future<bool> isComplete() async {
    final existing = await _database.select(_database.readerProfiles).get();
    return existing.isNotEmpty;
  }

  Future<void> save(OnboardingAnswers answers) async {
    if (!answers.isComplete) {
      throw StateError('El onboarding todavía no está completo.');
    }
    await _database.delete(_database.readerProfiles).go();
    await _database
        .into(_database.readerProfiles)
        .insert(
          ReaderProfilesCompanion.insert(
            motivations: answers.motivationsStorage,
            dailyGoalMinutes: answers.dailyGoalMinutes!,
            routine: answers.routine!.id,
            completedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
