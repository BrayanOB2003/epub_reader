import 'package:epub_reader/core/database/app_database.dart';

class BookReadingTime {
  const BookReadingTime({
    required this.bookId,
    required this.title,
    required this.sessions,
  });

  final int bookId;
  final String title;
  final List<ReadingSession> sessions;

  int get engagedSeconds =>
      sessions.fold(0, (total, session) => total + session.engagedSeconds);
}

List<BookReadingTime> readingTimeByBook({
  required Map<int, String> titles,
  required List<ReadingSession> sessions,
}) {
  final byBook = <int, List<ReadingSession>>{};
  for (final session in sessions) {
    if (!titles.containsKey(session.bookId)) continue;
    byBook.putIfAbsent(session.bookId, () => []).add(session);
  }

  final records = [
    for (final entry in byBook.entries)
      BookReadingTime(
        bookId: entry.key,
        title: titles[entry.key]!,
        sessions: [...entry.value]
          ..sort((a, b) => b.endedAt.compareTo(a.endedAt)),
      ),
  ];
  records.sort(
    (a, b) => b.sessions.first.endedAt.compareTo(a.sessions.first.endedAt),
  );
  return records;
}

class DailyReading {
  const DailyReading({required this.day, required this.engagedSeconds});

  final DateTime day;
  final int engagedSeconds;
}

List<DailyReading> weeklyReading({
  required Iterable<ReadingSession> sessions,
  required DateTime now,
}) {
  final today = _localDate(now);
  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );
  final totals = List<int>.filled(7, 0);
  for (final session in sessions) {
    final index = _calendarDaysBetween(monday, _localDate(session.startedAt));
    if (index < 0 || index > 6) continue;
    totals[index] += session.engagedSeconds;
  }
  return [
    for (var index = 0; index < 7; index++)
      DailyReading(
        day: DateTime(monday.year, monday.month, monday.day + index),
        engagedSeconds: totals[index],
      ),
  ];
}

DateTime _localDate(DateTime instant) {
  final local = instant.toLocal();
  return DateTime(local.year, local.month, local.day);
}

int _calendarDaysBetween(DateTime start, DateTime day) {
  final first = DateTime.utc(start.year, start.month, start.day);
  final second = DateTime.utc(day.year, day.month, day.day);
  return second.difference(first).inDays;
}

String formatReadingDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final hours = safe ~/ 3600;
  final minutes = (safe % 3600) ~/ 60;
  final rest = safe % 60;
  if (hours > 0) {
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes min';
  }
  if (minutes == 0) return '$rest s';
  if (rest == 0) return '$minutes min';
  return '$minutes min $rest s';
}

String formatReadingMoment(DateTime instant, {required DateTime now}) {
  final local = instant.toLocal();
  final current = now.toLocal();
  final time = '${_two(local.hour)}:${_two(local.minute)}';
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(current.year, current.month, current.day);
  if (day == today) return 'Hoy, $time';
  if (day == today.subtract(const Duration(days: 1))) return 'Ayer, $time';
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${local.day} ${months[local.month - 1]}, $time';
}

String _two(int value) => value.toString().padLeft(2, '0');
