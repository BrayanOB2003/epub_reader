import 'dart:typed_data';

import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';

const _archetypeMinSessions = 8;
const _methodicalMinSessions = 4;
const _antDayMax = Duration(minutes: 15);
const _marathonDay = Duration(minutes: 25);
const _onTime = Duration(minutes: 30);
const _hunterMinQuotes = 8;
const _topBooks = 3;

enum MonthArchetype {
  methodical,
  ant,
  marathoner,
  ideaHunter,
  earlyRiser,
  afternoon,
  nightOwl,
  nomad,
}

sealed class MonthArchetypeEvidence {
  const MonthArchetypeEvidence();
}

class MethodicalEvidence extends MonthArchetypeEvidence {
  const MethodicalEvidence({
    required this.onTime,
    required this.sessions,
    required this.hour,
  });

  final int onTime;
  final int sessions;
  final int hour;
}

class AntEvidence extends MonthArchetypeEvidence {
  const AntEvidence({required this.metDays, required this.plannedDays});

  final int metDays;
  final int plannedDays;
}

class MarathonerEvidence extends MonthArchetypeEvidence {
  const MarathonerEvidence({required this.averageSeconds});

  final int averageSeconds;
}

class HunterEvidence extends MonthArchetypeEvidence {
  const HunterEvidence({
    required this.sessionsWithQuotes,
    required this.sessions,
  });

  final int sessionsWithQuotes;
  final int sessions;
}

class BandEvidence extends MonthArchetypeEvidence {
  const BandEvidence({required this.percent});

  final int percent;
}

class NomadEvidence extends MonthArchetypeEvidence {
  const NomadEvidence();
}

class MonthArchetypeReport {
  const MonthArchetypeReport({required this.kind, required this.evidence});

  final MonthArchetype kind;
  final MonthArchetypeEvidence evidence;
}

class MonthPlan {
  const MonthPlan({
    required this.dailyGoalMinutes,
    required this.routineHour,
    required this.weekdays,
  });

  final int dailyGoalMinutes;
  final int? routineHour;
  final Set<ReadingWeekday> weekdays;
}

class MonthQuoteInput {
  const MonthQuoteInput({
    required this.id,
    required this.bookId,
    required this.savedAt,
    required this.text,
    required this.bookTitle,
  });

  final int id;
  final int bookId;
  final DateTime savedAt;
  final String text;
  final String bookTitle;
}

class MonthBookLine {
  const MonthBookLine({
    required this.bookId,
    required this.title,
    required this.engagedSeconds,
    required this.progress,
    required this.finished,
    this.coverBytes,
    this.horizon,
  });

  final int bookId;
  final String title;
  final Uint8List? coverBytes;
  final int engagedSeconds;
  final double progress;
  final bool finished;
  final ReadingHorizon? horizon;
}

class MonthQuoteLine {
  const MonthQuoteLine({required this.passage, required this.bookTitle});

  final String passage;
  final String bookTitle;
}

class MonthReadingReport {
  const MonthReadingReport({
    required this.month,
    required this.closed,
    required this.engagedSeconds,
    required this.books,
    this.metDays,
    this.plannedDays,
    this.minuteDeltaSeconds,
    this.comparedMonth,
    this.archetype,
    this.quote,
  });

  /// First local day of the month under review.
  final DateTime month;

  /// A month that has already ended. The one in progress omits the archetype
  /// and the comparison with the month before.
  final bool closed;
  final int engagedSeconds;
  final int? metDays;
  final int? plannedDays;

  /// Signed difference against [comparedMonth]. Positive means this month
  /// had more reading. Null when there is nothing to compare.
  final int? minuteDeltaSeconds;
  final DateTime? comparedMonth;
  final List<MonthBookLine> books;
  final MonthArchetypeReport? archetype;
  final MonthQuoteLine? quote;
}

Set<ReadingWeekday> monthPlanWeekdays(String? stored) {
  if (stored == null || !isReadingWeekdaysStorage(stored)) {
    return defaultReadingWeekdays;
  }
  return {
    for (final part in stored.split(',')) ReadingWeekday.byId(int.parse(part))!,
  };
}

/// The month the review shows: the last closed month that has reading, or the
/// current month when that is the only one with reading.
DateTime? monthOnReview({
  required Iterable<ReadingSession> sessions,
  required DateTime now,
}) {
  final today = _localDate(now);
  final current = DateTime(today.year, today.month);
  final previous = DateTime(today.year, today.month - 1);
  if (_monthHasSession(sessions, previous)) return previous;
  if (_monthHasSession(sessions, current)) return current;
  return null;
}

/// One month of reading, judged against the plan that is saved now.
///
/// The days of the plan are every chosen weekday in the calendar month, or up
/// to today when the month is still open. Saving the plan again does not drop
/// the days already lived.
MonthReadingReport? monthReadingReport({
  required Iterable<ReadingSession> sessions,
  required Iterable<Book> books,
  required Iterable<MonthQuoteInput> quotes,
  required MonthPlan? plan,
  required DateTime now,
}) {
  final month = monthOnReview(sessions: sessions, now: now);
  if (month == null) return null;
  final today = _localDate(now);
  final closed = month.year != today.year || month.month != today.month;
  final monthSessions = [
    for (final session in sessions)
      if (_inMonth(_localDate(session.startedAt), month)) session,
  ];
  final engagedSeconds = monthSessions.fold<int>(
    0,
    (total, session) => total + session.engagedSeconds,
  );
  final window = _window(month: month, today: today, closed: closed);
  final windowSessions = [
    for (final session in monthSessions)
      if (!_localDate(session.startedAt).isBefore(window.start) &&
          !_localDate(session.startedAt).isAfter(window.end))
        session,
  ];
  final daySeconds = <DateTime, int>{};
  for (final session in windowSessions) {
    final day = _localDate(session.startedAt);
    daySeconds[day] = (daySeconds[day] ?? 0) + session.engagedSeconds;
  }
  final goalSeconds = (plan?.dailyGoalMinutes ?? 0) * 60;
  final planned = plan == null
      ? (planned: 0, met: 0)
      : _plannedDays(
          start: window.start,
          end: window.end,
          weekdays: plan.weekdays,
          daySeconds: daySeconds,
          goalSeconds: goalSeconds,
        );
  final windowQuotes = [
    for (final quote in quotes)
      if (!_localDate(quote.savedAt).isBefore(window.start) &&
          !_localDate(quote.savedAt).isAfter(window.end))
        quote,
  ];
  final slice = _Slice(
    closed: closed,
    plan: plan,
    windowSessions: windowSessions,
    daySeconds: daySeconds,
    windowQuotes: windowQuotes,
    plannedDays: planned.planned,
    metDays: planned.met,
    goalSeconds: goalSeconds,
  );
  final delta = _delta(
    closed: closed,
    month: month,
    engagedSeconds: engagedSeconds,
    sessions: sessions,
  );
  return MonthReadingReport(
    month: month,
    closed: closed,
    engagedSeconds: engagedSeconds,
    metDays: planned.planned > 0 ? planned.met : null,
    plannedDays: planned.planned > 0 ? planned.planned : null,
    minuteDeltaSeconds: delta?.seconds,
    comparedMonth: delta?.month,
    books: _books(
      monthSessions: monthSessions,
      sessions: sessions,
      books: books,
      now: now,
    ),
    archetype: _archetype(slice),
    quote: _quote(quotes, month),
  );
}

class _Slice {
  const _Slice({
    required this.closed,
    required this.plan,
    required this.windowSessions,
    required this.daySeconds,
    required this.windowQuotes,
    required this.plannedDays,
    required this.metDays,
    required this.goalSeconds,
  });

  final bool closed;
  final MonthPlan? plan;
  final List<ReadingSession> windowSessions;
  final Map<DateTime, int> daySeconds;
  final List<MonthQuoteInput> windowQuotes;
  final int plannedDays;
  final int metDays;
  final int goalSeconds;
}

class _Delta {
  const _Delta(this.month, this.seconds);

  final DateTime month;
  final int seconds;
}

({DateTime start, DateTime end}) _window({
  required DateTime month,
  required DateTime today,
  required bool closed,
}) {
  final start = DateTime(month.year, month.month);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final end = closed || !today.isBefore(monthEnd) ? monthEnd : today;
  return (start: start, end: end);
}

({int planned, int met}) _plannedDays({
  required DateTime start,
  required DateTime end,
  required Set<ReadingWeekday> weekdays,
  required Map<DateTime, int> daySeconds,
  required int goalSeconds,
}) {
  var planned = 0;
  var met = 0;
  for (
    var day = start;
    !day.isAfter(end);
    day = day.add(const Duration(days: 1))
  ) {
    if (!weekdays.any((weekday) => weekday.id == day.weekday)) continue;
    planned++;
    if (_dayMet(daySeconds[day] ?? 0, goalSeconds)) met++;
  }
  return (planned: planned, met: met);
}

bool _dayMet(int seconds, int goalSeconds) =>
    goalSeconds > 0 && seconds >= goalSeconds;

_Delta? _delta({
  required bool closed,
  required DateTime month,
  required int engagedSeconds,
  required Iterable<ReadingSession> sessions,
}) {
  if (!closed) return null;
  final previous = DateTime(month.year, month.month - 1);
  final previousSeconds = sessions.fold<int>(0, (total, session) {
    if (!_inMonth(_localDate(session.startedAt), previous)) return total;
    return total + session.engagedSeconds;
  });
  if (previousSeconds <= 0 || previousSeconds == engagedSeconds) return null;
  return _Delta(previous, engagedSeconds - previousSeconds);
}

List<MonthBookLine> _books({
  required List<ReadingSession> monthSessions,
  required Iterable<ReadingSession> sessions,
  required Iterable<Book> books,
  required DateTime now,
}) {
  final byId = {for (final book in books) book.id: book};
  final grouped = <int, List<ReadingSession>>{};
  for (final session in monthSessions) {
    if (!byId.containsKey(session.bookId)) continue;
    grouped.putIfAbsent(session.bookId, () => []).add(session);
  }
  final lines = [
    for (final entry in grouped.entries)
      _bookLine(
        book: byId[entry.key]!,
        monthSessions: entry.value,
        sessions: sessions,
        now: now,
      ),
  ];
  lines.sort((a, b) {
    final byTime = b.book.engagedSeconds.compareTo(a.book.engagedSeconds);
    if (byTime != 0) return byTime;
    return b.latest.compareTo(a.latest);
  });
  return [for (final line in lines.take(_topBooks)) line.book];
}

class _BookSort {
  const _BookSort(this.book, this.latest);

  final MonthBookLine book;
  final DateTime latest;
}

_BookSort _bookLine({
  required Book book,
  required List<ReadingSession> monthSessions,
  required Iterable<ReadingSession> sessions,
  required DateTime now,
}) {
  final seconds = monthSessions.fold<int>(
    0,
    (total, session) => total + session.engagedSeconds,
  );
  var latest = monthSessions.first.endedAt;
  for (final session in monthSessions) {
    if (session.endedAt.isAfter(latest)) latest = session.endedAt;
  }
  final finished = book.progress >= 1;
  final all = [
    for (final session in sessions)
      if (session.bookId == book.id) session,
  ];
  final allSeconds = all.fold<int>(
    0,
    (total, session) => total + session.engagedSeconds,
  );
  return _BookSort(
    MonthBookLine(
      bookId: book.id,
      title: book.title,
      coverBytes: book.coverBytes,
      engagedSeconds: seconds,
      progress: book.progress,
      finished: finished,
      horizon: finished
          ? null
          : bookReadingPace(
              engagedSeconds: allSeconds,
              progress: book.progress,
              sessions: all,
              now: now,
            ).horizon,
    ),
    latest,
  );
}

MonthQuoteLine? _quote(Iterable<MonthQuoteInput> quotes, DateTime month) {
  MonthQuoteInput? latest;
  for (final quote in quotes) {
    if (quote.text.trim().isEmpty) continue;
    if (!_inMonth(_localDate(quote.savedAt), month)) continue;
    if (latest == null ||
        quote.savedAt.isAfter(latest.savedAt) ||
        (quote.savedAt == latest.savedAt && quote.id > latest.id)) {
      latest = quote;
    }
  }
  if (latest == null) return null;
  return MonthQuoteLine(
    passage: latest.text.trim(),
    bookTitle: latest.bookTitle,
  );
}

/// First match wins: how the habit is held, then quotes, then the hour.
MonthArchetypeReport? _archetype(_Slice slice) {
  if (!slice.closed || slice.windowSessions.length < _archetypeMinSessions) {
    return null;
  }
  return _methodical(slice) ??
      _ant(slice) ??
      _marathon(slice) ??
      _hunter(slice) ??
      _timeOfDay(slice) ??
      _nomad(slice);
}

MonthArchetypeReport? _methodical(_Slice slice) {
  final plan = slice.plan;
  final hour = plan?.routineHour;
  if (plan == null || hour == null) return null;
  final planned = [
    for (final session in slice.windowSessions)
      if (plan.weekdays.any(
        (day) => day.id == _localDate(session.startedAt).weekday,
      ))
        session,
  ];
  if (planned.length < _methodicalMinSessions) return null;
  final onTime = planned
      .where((session) => _nearHour(session.startedAt, hour))
      .length;
  if (onTime * 10 < planned.length * 7) return null;
  final days = <DateTime>{
    for (final session in planned) _localDate(session.startedAt),
  };
  final met = days
      .where((day) => _dayMet(slice.daySeconds[day] ?? 0, slice.goalSeconds))
      .length;
  if (met * 2 <= days.length) return null;
  return MonthArchetypeReport(
    kind: MonthArchetype.methodical,
    evidence: MethodicalEvidence(
      onTime: onTime,
      sessions: planned.length,
      hour: hour,
    ),
  );
}

MonthArchetypeReport? _ant(_Slice slice) {
  if (slice.plan == null || slice.plannedDays == 0) return null;
  if (slice.metDays * 10 < slice.plannedDays * 8) return null;
  final reading = [
    for (final seconds in slice.daySeconds.values)
      if (seconds > 0) seconds,
  ];
  if (reading.isEmpty ||
      reading.any((seconds) => seconds > _antDayMax.inSeconds)) {
    return null;
  }
  return MonthArchetypeReport(
    kind: MonthArchetype.ant,
    evidence: AntEvidence(
      metDays: slice.metDays,
      plannedDays: slice.plannedDays,
    ),
  );
}

MonthArchetypeReport? _marathon(_Slice slice) {
  final plan = slice.plan;
  if (plan == null) return null;
  final days = [
    for (final seconds in slice.daySeconds.values)
      if (seconds > 0) seconds,
  ];
  if (days.isEmpty) return null;
  final average =
      days.reduce((total, seconds) => total + seconds) ~/ days.length;
  final goal = plan.dailyGoalMinutes * 60;
  if (average < _marathonDay.inSeconds || average <= goal) return null;
  return MonthArchetypeReport(
    kind: MonthArchetype.marathoner,
    evidence: MarathonerEvidence(averageSeconds: average),
  );
}

MonthArchetypeReport? _hunter(_Slice slice) {
  final sessions = slice.windowSessions;
  if (sessions.isEmpty || slice.windowQuotes.length < _hunterMinQuotes) {
    return null;
  }
  final withQuotes = sessions
      .where(
        (session) =>
            slice.windowQuotes.any((quote) => _quoteInSession(quote, session)),
      )
      .length;
  if (withQuotes * 3 < sessions.length) return null;
  return MonthArchetypeReport(
    kind: MonthArchetype.ideaHunter,
    evidence: HunterEvidence(
      sessionsWithQuotes: withQuotes,
      sessions: sessions.length,
    ),
  );
}

MonthArchetypeReport? _timeOfDay(_Slice slice) {
  final totals = <_Band, int>{};
  var total = 0;
  for (final session in slice.windowSessions) {
    final band = _band(session.startedAt.toLocal().hour);
    final seconds = session.engagedSeconds;
    total += seconds;
    if (band == null || seconds <= 0) continue;
    totals[band] = (totals[band] ?? 0) + seconds;
  }
  if (total <= 0) return null;
  const order = [_Band.early, _Band.afternoon, _Band.night];
  for (final band in order) {
    final seconds = totals[band] ?? 0;
    if (seconds * 10 < total * 6) continue;
    return MonthArchetypeReport(
      kind: switch (band) {
        _Band.early => MonthArchetype.earlyRiser,
        _Band.afternoon => MonthArchetype.afternoon,
        _Band.night => MonthArchetype.nightOwl,
      },
      evidence: BandEvidence(percent: (seconds * 100 / total).round()),
    );
  }
  return null;
}

MonthArchetypeReport? _nomad(_Slice slice) {
  final total = slice.windowSessions.fold<int>(
    0,
    (sum, session) => sum + session.engagedSeconds,
  );
  if (total <= 0) return null;
  return const MonthArchetypeReport(
    kind: MonthArchetype.nomad,
    evidence: NomadEvidence(),
  );
}

bool _quoteInSession(MonthQuoteInput quote, ReadingSession session) {
  if (quote.bookId != session.bookId) return false;
  if (quote.savedAt.isBefore(session.startedAt)) return false;
  return !quote.savedAt.isAfter(session.endedAt);
}

bool _nearHour(DateTime startedAt, int hour) {
  final local = startedAt.toLocal();
  final target = DateTime(local.year, local.month, local.day, hour);
  return local.difference(target).abs() <= _onTime;
}

enum _Band { early, afternoon, night }

/// Morning 5:00–11:59, afternoon 12:00–18:59, night 19:00–3:59. 4:00 is in none.
_Band? _band(int hour) {
  if (hour >= 5 && hour <= 11) return _Band.early;
  if (hour >= 12 && hour <= 18) return _Band.afternoon;
  if (hour >= 19 || hour <= 3) return _Band.night;
  return null;
}

bool _monthHasSession(Iterable<ReadingSession> sessions, DateTime month) {
  for (final session in sessions) {
    if (_inMonth(_localDate(session.startedAt), month)) return true;
  }
  return false;
}

bool _inMonth(DateTime day, DateTime month) =>
    day.year == month.year && day.month == month.month;

DateTime _localDate(DateTime instant) {
  final local = instant.toLocal();
  return DateTime(local.year, local.month, local.day);
}
