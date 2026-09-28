import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';

enum ReadingMotivation {
  readMore('read_more'),
  habit('habit'),
  finishBooks('finish_books'),
  learn('learn'),
  timeForMe('time_for_me');

  const ReadingMotivation(this.id);

  final String id;

  String label(AppLocalizations l10n) {
    return switch (this) {
      ReadingMotivation.readMore => l10n.motivationReadMore,
      ReadingMotivation.habit => l10n.motivationHabit,
      ReadingMotivation.finishBooks => l10n.motivationFinishBooks,
      ReadingMotivation.learn => l10n.motivationLearn,
      ReadingMotivation.timeForMe => l10n.motivationTimeForMe,
    };
  }

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

  factory OnboardingAnswers.fromStored({
    required String motivations,
    required int dailyGoalMinutes,
    required String routine,
    int? routineHour,
    String? routineDays,
  }) {
    return OnboardingAnswers(
      motivations: {
        for (final id in motivations.split(','))
          if (ReadingMotivation.byId(id) != null) ReadingMotivation.byId(id)!,
      },
      dailyGoalMinutes: readingGoalMinutes.contains(dailyGoalMinutes)
          ? dailyGoalMinutes
          : null,
      routine: ReadingRoutine.byId(routine),
      routineHour: routineHour,
      weekdays: _storedWeekdays(routineDays),
    );
  }

  String get weekdaysStorage => readingWeekdaysStorage(weekdays);

  String get motivationsStorage =>
      (motivations.map((motivation) => motivation.id).toList()..sort()).join(
        ',',
      );
}

Set<ReadingWeekday> _storedWeekdays(String? value) {
  if (value == null || !isReadingWeekdaysStorage(value)) {
    return defaultReadingWeekdays;
  }
  return {
    for (final part in value.split(',')) ReadingWeekday.byId(int.parse(part))!,
  };
}

String? onboardingRedirect({
  required bool? completed,
  required String location,
  bool editing = false,
}) {
  const boot = '/boot';
  const onboarding = '/onboarding';
  const library = '/library';
  if (completed == null) return location == boot ? null : boot;
  if (!completed) return location == onboarding ? null : onboarding;
  if (editing && location == onboarding) return null;
  if (location == boot || location == onboarding) return library;
  return null;
}
