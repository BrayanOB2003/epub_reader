import 'package:epub_reader/l10n/app_localizations.dart';

enum ReadingRoutine {
  morning('morning', 5, 11),
  afternoon('afternoon', 12, 18),
  night('night', 19, 23);

  const ReadingRoutine(this.id, this.firstHour, this.lastHour);

  final String id;
  final int firstHour;
  final int lastHour;

  String label(AppLocalizations l10n) {
    return switch (this) {
      ReadingRoutine.morning => l10n.routineMorning,
      ReadingRoutine.afternoon => l10n.routineAfternoon,
      ReadingRoutine.night => l10n.routineNight,
    };
  }

  List<int> get hours => [
    for (var hour = firstHour; hour <= lastHour; hour++) hour,
  ];

  bool allows(int hour) => hour >= firstHour && hour <= lastHour;

  static ReadingRoutine? byId(String id) {
    for (final routine in values) {
      if (routine.id == id) return routine;
    }
    return null;
  }
}

String readingHourLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';

enum ReadingWeekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const ReadingWeekday(this.id);

  final int id;

  String letter(AppLocalizations l10n) {
    return switch (this) {
      ReadingWeekday.monday => l10n.mondayLetter,
      ReadingWeekday.tuesday => l10n.tuesdayLetter,
      ReadingWeekday.wednesday => l10n.wednesdayLetter,
      ReadingWeekday.thursday => l10n.thursdayLetter,
      ReadingWeekday.friday => l10n.fridayLetter,
      ReadingWeekday.saturday => l10n.saturdayLetter,
      ReadingWeekday.sunday => l10n.sundayLetter,
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      ReadingWeekday.monday => l10n.monday,
      ReadingWeekday.tuesday => l10n.tuesday,
      ReadingWeekday.wednesday => l10n.wednesday,
      ReadingWeekday.thursday => l10n.thursday,
      ReadingWeekday.friday => l10n.friday,
      ReadingWeekday.saturday => l10n.saturday,
      ReadingWeekday.sunday => l10n.sunday,
    };
  }

  static ReadingWeekday? byId(int id) {
    for (final day in values) {
      if (day.id == id) return day;
    }
    return null;
  }
}

const defaultReadingWeekdays = {
  ReadingWeekday.monday,
  ReadingWeekday.tuesday,
  ReadingWeekday.wednesday,
  ReadingWeekday.thursday,
  ReadingWeekday.friday,
  ReadingWeekday.saturday,
  ReadingWeekday.sunday,
};

String readingWeekdaysStorage(Iterable<ReadingWeekday> days) {
  return (days.map((day) => day.id.toString()).toList()..sort()).join(',');
}

bool isReadingWeekdaysStorage(String value) {
  if (value.isEmpty) return false;
  final seen = <int>{};
  for (final part in value.split(',')) {
    final id = int.tryParse(part);
    if (id == null || !seen.add(id) || ReadingWeekday.byId(id) == null) {
      return false;
    }
  }
  return true;
}
