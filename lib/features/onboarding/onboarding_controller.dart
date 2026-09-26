import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(readerProfileStoreProvider).exists();
  }

  Future<void> complete(OnboardingAnswers answers) async {
    if (!answers.isComplete) {
      throw StateError('El onboarding todavía no está completo.');
    }
    await ref
        .read(readerProfileStoreProvider)
        .save(
          motivations: answers.motivationsStorage,
          dailyGoalMinutes: answers.dailyGoalMinutes!,
          routine: answers.routine!.id,
        );
    state = const AsyncData(true);
  }
}
