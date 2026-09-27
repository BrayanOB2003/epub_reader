import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';

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

class OnboardingAnswers {
  const OnboardingAnswers({
    this.motivations = const {},
    this.dailyGoalMinutes,
    this.routine,
    this.routineHour,
    this.weekdays = defaultReadingWeekdays,
  });

  final Set<ReadingMotivation> motivations;
  final int? dailyGoalMinutes;
  final ReadingRoutine? routine;
  final int? routineHour;
  final Set<ReadingWeekday> weekdays;

  bool get hasMotivations => motivations.isNotEmpty;

  bool get hasGoal => readingGoalMinutes.contains(dailyGoalMinutes);

  bool get hasReadingTime {
    final period = routine;
    final hour = routineHour;
    if (period == null || hour == null || weekdays.isEmpty) return false;
    return period.allows(hour);
  }

  bool get isComplete => hasMotivations && hasGoal && hasReadingTime;

  OnboardingAnswers copyWith({
    Set<ReadingMotivation>? motivations,
    int? dailyGoalMinutes,
    ReadingRoutine? routine,
    int? routineHour,
    Set<ReadingWeekday>? weekdays,
  }) {
    return OnboardingAnswers(
      motivations: motivations ?? this.motivations,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      routine: routine ?? this.routine,
      routineHour: routineHour ?? this.routineHour,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  OnboardingAnswers withRoutine(ReadingRoutine period) {
    final hour = routineHour;
    return OnboardingAnswers(
      motivations: motivations,
      dailyGoalMinutes: dailyGoalMinutes,
      routine: period,
      routineHour: hour != null && period.allows(hour) ? hour : null,
      weekdays: weekdays,
    );
  }

  String get weekdaysStorage => readingWeekdaysStorage(weekdays);

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
