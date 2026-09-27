enum ReadingRoutine {
  morning('morning', 'Mañana', 5, 11),
  afternoon('afternoon', 'Tarde', 12, 18),
  night('night', 'Noche', 19, 23);

  const ReadingRoutine(this.id, this.label, this.firstHour, this.lastHour);

  final String id;
  final String label;
  final int firstHour;
  final int lastHour;

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
  monday(1, 'L', 'Lunes'),
  tuesday(2, 'M', 'Martes'),
  wednesday(3, 'X', 'Miércoles'),
  thursday(4, 'J', 'Jueves'),
  friday(5, 'V', 'Viernes'),
  saturday(6, 'S', 'Sábado'),
  sunday(7, 'D', 'Domingo');

  const ReadingWeekday(this.id, this.letter, this.label);

  final int id;
  final String letter;
  final String label;

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
