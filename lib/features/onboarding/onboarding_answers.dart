enum ReadingMotivation {
  readMore('read_more', 'Leer más'),
  habit('habit', 'Crear un hábito'),
  finishBooks('finish_books', 'Terminar más libros'),
  learn('learn', 'Aprender cosas nuevas'),
  timeForMe('time_for_me', 'Tener un momento para mí');

  const ReadingMotivation(this.id, this.label);

  final String id;
  final String label;

  static ReadingMotivation? byId(String id) {
    for (final motivation in values) {
      if (motivation.id == id) return motivation;
    }
    return null;
  }
}

enum ReadingRoutine {
  morning('morning', 'Mañana'),
  afternoon('afternoon', 'Tarde'),
  night('night', 'Noche');

  const ReadingRoutine(this.id, this.label);

  final String id;
  final String label;

  static ReadingRoutine? byId(String id) {
    for (final routine in values) {
      if (routine.id == id) return routine;
    }
    return null;
  }
}

const readingGoalMinutes = [5, 10, 20, 30];

class OnboardingAnswers {
  const OnboardingAnswers({
    this.motivations = const {},
    this.dailyGoalMinutes,
    this.routine,
  });

  final Set<ReadingMotivation> motivations;
  final int? dailyGoalMinutes;
  final ReadingRoutine? routine;

  bool get hasMotivations => motivations.isNotEmpty;

  bool get hasGoal => readingGoalMinutes.contains(dailyGoalMinutes);

  bool get hasRoutine => routine != null;

  bool get isComplete => hasMotivations && hasGoal && hasRoutine;

  OnboardingAnswers copyWith({
    Set<ReadingMotivation>? motivations,
    int? dailyGoalMinutes,
    ReadingRoutine? routine,
  }) {
    return OnboardingAnswers(
      motivations: motivations ?? this.motivations,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      routine: routine ?? this.routine,
    );
  }

  String get motivationsStorage =>
      (motivations.map((motivation) => motivation.id).toList()..sort()).join(
        ',',
      );
}

String? onboardingRedirect({
  required bool? completed,
  required String location,
}) {
  const boot = '/boot';
  const onboarding = '/onboarding';
  const library = '/library';
  if (completed == null) return location == boot ? null : boot;
  if (!completed) return location == onboarding ? null : onboarding;
  if (location == boot || location == onboarding) return library;
  return null;
}
