import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/reading_estimate.dart';

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

const _horizonMinSessions = 3;
const _horizonMinDays = 2;
const _horizonWindowDays = 14;
const _horizonWeekSpanDays = 7;

/// Below this, a week-rate is still "less than a week", not "one week".
const _underAWeek = 0.75;

enum ReadingHorizonKind { underAWeek, weeks, sittings }

class ReadingHorizon {
  const ReadingHorizon.underAWeek()
    : kind = ReadingHorizonKind.underAWeek,
      count = null;

  const ReadingHorizon.weeks(int this.count) : kind = ReadingHorizonKind.weeks;

  const ReadingHorizon.sittings(int this.count)
    : kind = ReadingHorizonKind.sittings;

  final ReadingHorizonKind kind;
  final int? count;
}

class BookReadingPace {
  const BookReadingPace({
    this.remainingMinutes,
    this.minutesPerTenPercent,
    this.horizon,
  });

  final int? remainingMinutes;
  final int? minutesPerTenPercent;
  final ReadingHorizon? horizon;
}

class BookReadingReport {
  const BookReadingReport({
    required this.book,
    required this.engagedSeconds,
    required this.pace,
  });

  final Book book;
  final int engagedSeconds;
  final BookReadingPace pace;
}

/// Every library book that has a session, newest visit first.
List<BookReadingReport> bookReadingReports({
  required List<Book> books,
  required List<ReadingSession> sessions,
  required DateTime now,
}) {
  final byId = {for (final book in books) book.id: book};
  final grouped = readingTimeByBook(
    titles: {for (final book in books) book.id: book.title},
    sessions: sessions,
  );
  final reports = <BookReadingReport>[];
  for (final record in grouped) {
    final book = byId[record.bookId];
    if (book == null) continue;
    reports.add(
      BookReadingReport(
        book: book,
        engagedSeconds: record.engagedSeconds,
        pace: bookReadingPace(
          engagedSeconds: record.engagedSeconds,
          progress: book.progress,
          sessions: record.sessions,
          now: now,
        ),
      ),
    );
  }
  return reports;
}

/// The book of the latest session that is still in the library.
BookReadingReport? currentBookReading({
  required List<Book> books,
  required List<ReadingSession> sessions,
  required DateTime now,
}) {
  final reports = bookReadingReports(
    books: books,
    sessions: sessions,
    now: now,
  );
  if (reports.isEmpty) return null;
  return reports.first;
}

/// Remaining time and pace share [estimateReading]. The horizon uses only
/// recent sessions of this book, and stays empty until several of them fall
/// on more than one day.
BookReadingPace bookReadingPace({
  required int engagedSeconds,
  required double progress,
  required List<ReadingSession> sessions,
  required DateTime now,
}) {
  final remaining = estimateReading(
    engagedSeconds: engagedSeconds,
    progress: progress,
  ).bookMinutes;
  return BookReadingPace(
    remainingMinutes: remaining,
    minutesPerTenPercent: _minutesPerTenPercent(
      engagedSeconds: engagedSeconds,
      progress: progress,
    ),
    horizon: remaining == null
        ? null
        : _horizon(remainingMinutes: remaining, sessions: sessions, now: now),
  );
}

int? _minutesPerTenPercent({
  required int engagedSeconds,
  required double progress,
}) {
  if (engagedSeconds < readingEstimateMinSeconds) return null;
  if (progress < readingEstimateMinProgress || progress >= 1) return null;
  return readingMinutes((engagedSeconds / progress * 0.1).round());
}

ReadingHorizon? _horizon({
  required int remainingMinutes,
  required List<ReadingSession> sessions,
  required DateTime now,
}) {
  final today = _localDate(now);
  final windowStart = today.subtract(
    const Duration(days: _horizonWindowDays - 1),
  );
  final recent = [
    for (final session in sessions)
      if (!_localDate(session.startedAt).isBefore(windowStart)) session,
  ];
  if (recent.length < _horizonMinSessions) return null;
  final days = <DateTime>{
    for (final session in recent) _localDate(session.startedAt),
  };
  if (days.length < _horizonMinDays) return null;
  final seconds = recent.fold<int>(
    0,
    (total, session) => total + session.engagedSeconds,
  );
  if (seconds <= 0) return null;

  var earliest = days.first;
  for (final day in days) {
    if (day.isBefore(earliest)) earliest = day;
  }
  final spanDays = _calendarDaysBetween(earliest, today) + 1;
  if (spanDays < 1) return null;
  if (spanDays < _horizonWeekSpanDays) {
    final averageMinutes = seconds / recent.length / 60;
    if (averageMinutes <= 0) return null;
    final sittings = remainingMinutes / averageMinutes;
    return ReadingHorizon.sittings(sittings.round().clamp(1, 9999));
  }

  final weeklyMinutes = (seconds / 60) / (spanDays / 7);
  if (weeklyMinutes <= 0) return null;
  final weeks = remainingMinutes / weeklyMinutes;
  if (weeks < _underAWeek) return const ReadingHorizon.underAWeek();
  return ReadingHorizon.weeks(weeks.round().clamp(1, 9999));
}

class DailyReading {
  const DailyReading({required this.day, required this.engagedSeconds});

  final DateTime day;
  final int engagedSeconds;
}

enum ReadingDayMark { none, partial, met }

class ReadingCalendarDay {
  const ReadingCalendarDay({
    required this.day,
    required this.mark,
    required this.engagedSeconds,
  });

  final DateTime day;
  final ReadingDayMark mark;
  final int engagedSeconds;
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

ReadingCalendarDay _calendarDay({
  required DateTime date,
  required int engagedSeconds,
  required int? goalSeconds,
}) {
  return ReadingCalendarDay(
    day: date,
    engagedSeconds: engagedSeconds,
    mark: readingDayMark(
      engagedSeconds: engagedSeconds,
      goalSeconds: goalSeconds,
    ),
  );
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
  int? goalSeconds,
  int? Function(DateTime day)? goalOn,
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
        _calendarDay(
          date: DateTime(first.year, first.month, day),
          engagedSeconds: totals[day] ?? 0,
          goalSeconds: goalOn == null
              ? goalSeconds
              : goalOn(DateTime(first.year, first.month, day)),
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

String formatReadingMoment(
  DateTime instant, {
  required DateTime now,
  String languageCode = 'es',
}) {
  final local = instant.toLocal();
  final current = now.toLocal();
  final time = '${_two(local.hour)}:${_two(local.minute)}';
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(current.year, current.month, current.day);
  final english = languageCode == 'en';
  if (day == today) return '${english ? 'Today' : 'Hoy'}, $time';
  if (day == today.subtract(const Duration(days: 1))) {
    return '${english ? 'Yesterday' : 'Ayer'}, $time';
  }
  final months = english ? _shortMonthsEn : _shortMonths;
  return '${local.day} ${months[local.month - 1]}, $time';
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

const _shortMonthsEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
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

const _monthNamesEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatReadingMonth(DateTime month, {String languageCode = 'es'}) {
  if (languageCode == 'en') {
    return '${_monthNamesEn[month.month - 1]} ${month.year}';
  }
  final name = _monthNames[month.month - 1];
  return '${name[0].toUpperCase()}${name.substring(1)} ${month.year}';
}

String readingMonthName(DateTime month, String languageCode) {
  if (languageCode == 'en') return _monthNamesEn[month.month - 1];
  return _monthNames[month.month - 1];
}

String _two(int value) => value.toString().padLeft(2, '0');
