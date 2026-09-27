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

enum ReadingDayMark { none, partial, met }

class ReadingCalendarDay {
  const ReadingCalendarDay({required this.day, required this.mark});

  final DateTime day;
  final ReadingDayMark mark;
}

class ReadingMonth {
  const ReadingMonth({
    required this.month,
    required this.leadingBlanks,
    required this.days,
  });

  final DateTime month;
  final int leadingBlanks;
  final List<ReadingCalendarDay> days;
}

ReadingDayMark readingDayMark({
  required int engagedSeconds,
  required int? goalSeconds,
}) {
  if (engagedSeconds <= 0) return ReadingDayMark.none;
  if (goalSeconds == null || goalSeconds <= 0) return ReadingDayMark.partial;
  if (engagedSeconds >= goalSeconds) return ReadingDayMark.met;
  return ReadingDayMark.partial;
}

ReadingMonth readingMonth({
  required Iterable<ReadingSession> sessions,
  required DateTime month,
  required int? goalSeconds,
}) {
  final first = DateTime(month.year, month.month);
  final totals = <int, int>{};
  for (final session in sessions) {
    final day = _localDate(session.startedAt);
    if (day.year != first.year || day.month != first.month) continue;
    totals[day.day] = (totals[day.day] ?? 0) + session.engagedSeconds;
  }
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return ReadingMonth(
    month: first,
    leadingBlanks: first.weekday - DateTime.monday,
    days: [
      for (var day = 1; day <= lastDay; day++)
        ReadingCalendarDay(
          day: DateTime(first.year, first.month, day),
          mark: readingDayMark(
            engagedSeconds: totals[day] ?? 0,
            goalSeconds: goalSeconds,
          ),
        ),
    ],
  );
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
  return '${local.day} ${_shortMonths[local.month - 1]}, $time';
}

const _shortMonths = [
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

const _monthNames = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String formatReadingMonth(DateTime month) {
  final name = _monthNames[month.month - 1];
  return '${name[0].toUpperCase()}${name.substring(1)} ${month.year}';
}

String _two(int value) => value.toString().padLeft(2, '0');
