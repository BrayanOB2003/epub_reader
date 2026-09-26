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
