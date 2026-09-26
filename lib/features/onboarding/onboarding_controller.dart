import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingStoreProvider = Provider<OnboardingStore>((ref) {
  return OnboardingStore(ref.watch(databaseProvider));
});

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(onboardingStoreProvider).isComplete();
  }

  Future<void> complete(OnboardingAnswers answers) async {
    await ref.read(onboardingStoreProvider).save(answers);
    state = const AsyncData(true);
  }
}
