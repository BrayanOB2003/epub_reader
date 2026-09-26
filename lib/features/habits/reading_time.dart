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
