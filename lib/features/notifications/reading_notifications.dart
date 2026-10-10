import 'dart:convert';

import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';

const stalledReadingDays = 3;
const readingStreakMinimum = 3;
const readingNotificationHorizon = 7;
const unfinishedBookProgress = 0.98;
const startedBookProgress = 0.02;
const goalMetNotificationId = 2;
const readingScheduleIdStart = 10;

enum ReadingNotificationKind { routine, goalRemaining, goalMet, resume, streak }

class NotificationSession {
  const NotificationSession({
    required this.bookId,
    required this.startedAt,
    required this.endedAt,
    required this.engagedSeconds,
  });

  final int bookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int engagedSeconds;
}

class NotificationBook {
  const NotificationBook({
    required this.id,
    required this.title,
    required this.progress,
    this.locatorJson,
  });

  final int id;
  final String title;
  final double progress;
  final String? locatorJson;
}

class PlannedReadingNotification {
  const PlannedReadingNotification({
    required this.id,
    required this.kind,
    required this.at,
    required this.location,
    this.goalMinutes,
    this.minutesLeft,
    this.streakDays,
    this.chapter,
    this.section,
    this.bookTitle,
    this.hourLabel,
  });

  final int id;
  final ReadingNotificationKind kind;
  final DateTime? at;
  final String location;
  final int? goalMinutes;
  final int? minutesLeft;
  final int? streakDays;
  final int? chapter;
  final String? section;
  final String? bookTitle;
  final String? hourLabel;
}

/// Upcoming reminders for the reading hour.
///
/// The next open slot carries the most specific message: minutes left, a
/// streak about to break, or a book left unfinished. Later days stay on the
/// routine reminder, because those totals are not known yet.
List<PlannedReadingNotification> planReadingNotifications({
  required DateTime now,
  required int goalMinutes,
  required int hour,
  required Set<int> weekdays,
  required List<NotificationSession> sessions,
  required List<NotificationBook> books,
}) {
  if (weekdays.isEmpty || hour < 0 || hour > 23 || goalMinutes <= 0) {
    return const [];
  }
  final moments = routineMoments(now: now, hour: hour, weekdays: weekdays);
  final todaySeconds = readingSecondsOnDay(sessions, now);
  final goalSeconds = goalMinutes * 60;
  final stalled = _stalledBook(books: books, sessions: sessions, now: now);
  final streak = readingStreakDays(
    sessions: sessions,
    today: now,
    includeToday: false,
  );
  final atRisk = todaySeconds <= 0 && streak >= readingStreakMinimum;
  final todayBook = _bookReadOn(sessions, books, now);
  final planned = <PlannedReadingNotification>[];
  var resumeUsed = false;

  for (final moment in moments) {
    if (planned.length >= readingNotificationHorizon) break;
    final id = readingScheduleIdStart + planned.length;
    final today = _sameDay(moment, now);
    if (today && todaySeconds >= goalSeconds) continue;
    if (today && todaySeconds > 0) {
      planned.add(
        PlannedReadingNotification(
          id: id,
          kind: ReadingNotificationKind.goalRemaining,
          at: moment,
          location: todayBook == null ? '/library' : '/read/${todayBook.id}',
          minutesLeft: minutesRemaining(goalMinutes, todaySeconds),
        ),
      );
      continue;
    }
    if (today && atRisk) {
      planned.add(
        PlannedReadingNotification(
          id: id,
          kind: ReadingNotificationKind.streak,
          at: moment,
          location: '/time',
          streakDays: streak,
        ),
      );
      continue;
    }
    if (!resumeUsed && stalled != null) {
      resumeUsed = true;
      final place = readingPlace(stalled.locatorJson);
      planned.add(
        PlannedReadingNotification(
          id: id,
          kind: ReadingNotificationKind.resume,
          at: moment,
          location: '/read/${stalled.id}',
          chapter: place.chapter,
          section: place.section,
          bookTitle: stalled.title,
        ),
      );
      continue;
    }
    planned.add(
      PlannedReadingNotification(
        id: id,
        kind: ReadingNotificationKind.routine,
        at: moment,
        location: '/library',
        goalMinutes: goalMinutes,
        hourLabel: readingHourLabel(hour),
      ),
    );
  }
  return planned;
}

PlannedReadingNotification goalMetNotification(int goalMinutes) {
  return PlannedReadingNotification(
    id: goalMetNotificationId,
    kind: ReadingNotificationKind.goalMet,
    at: null,
    location: '/time',
    goalMinutes: goalMinutes,
  );
}

bool dailyGoalJustMet({
  required Iterable<NotificationSession> before,
  required Iterable<NotificationSession> after,
  required int goalMinutes,
  required DateTime now,
}) {
  return readingGoalCrossed(
    beforeSeconds: readingSecondsOnDay(before, now),
    afterSeconds: readingSecondsOnDay(after, now),
    goalMinutes: goalMinutes,
  );
}

bool readingGoalCrossed({
  required int? beforeSeconds,
  required int afterSeconds,
  required int goalMinutes,
}) {
  if (beforeSeconds == null || goalMinutes <= 0) return false;
  final goal = goalMinutes * 60;
  return beforeSeconds < goal && afterSeconds >= goal;
}

int readingSecondsOnDay(Iterable<NotificationSession> sessions, DateTime day) {
  final date = _localDate(day);
  var total = 0;
  for (final session in sessions) {
    if (_localDate(session.startedAt) != date) continue;
    if (session.engagedSeconds <= 0) continue;
    total += session.engagedSeconds;
  }
  return total;
}

int minutesRemaining(int goalMinutes, int engagedSeconds) {
  final left = goalMinutes * 60 - engagedSeconds;
  if (left <= 0) return 0;
  return (left + 59) ~/ 60;
}

int readingStreakDays({
  required Iterable<NotificationSession> sessions,
  required DateTime today,
  required bool includeToday,
}) {
  final days = <DateTime>{
    for (final session in sessions)
      if (session.engagedSeconds > 0) _localDate(session.startedAt),
  };
  var cursor = _localDate(today);
  if (!includeToday) cursor = cursor.subtract(const Duration(days: 1));
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

List<DateTime> routineMoments({
  required DateTime now,
  required int hour,
  required Set<int> weekdays,
  int limit = readingNotificationHorizon,
}) {
  final moments = <DateTime>[];
  final start = _localDate(now);
  for (var offset = 0; moments.length < limit && offset < 21; offset++) {
    final day = DateTime(start.year, start.month, start.day + offset);
    if (!weekdays.contains(day.weekday)) continue;
    final moment = DateTime(day.year, day.month, day.day, hour);
    if (!moment.isAfter(now)) continue;
    moments.add(moment);
  }
  return moments;
}

({int? chapter, String? section}) readingPlace(String? locatorJson) {
  if (locatorJson == null || locatorJson.isEmpty) {
    return (chapter: null, section: null);
  }
  try {
    final decoded = jsonDecode(locatorJson);
    if (decoded is! Map) return (chapter: null, section: null);
    final title = decoded['title'];
    final locations = decoded['locations'];
    int? chapter;
    if (locations is Map) {
      final position = locations['position'];
      if (position is int && position > 0) chapter = position;
    }
    final section = title is String && title.trim().isNotEmpty
        ? title.trim()
        : null;
    return (chapter: chapter, section: section);
  } catch (_) {
    return (chapter: null, section: null);
  }
}

Set<int> notificationWeekdays(String? stored) {
  if (stored == null || !isReadingWeekdaysStorage(stored)) {
    return {for (final day in defaultReadingWeekdays) day.id};
  }
  return {for (final part in stored.split(',')) int.parse(part)};
}

LocalNotificationMessage readingNotificationMessage(
  PlannedReadingNotification notification,
  AppLocalizations l10n,
) {
  final bookTitle = _shownTitle(notification.bookTitle, l10n);
  final title = switch (notification.kind) {
    ReadingNotificationKind.routine => l10n.notificationRoutineTitle,
    ReadingNotificationKind.goalRemaining => l10n.notificationGoalTitle,
    ReadingNotificationKind.goalMet => l10n.notificationGoalMetTitle,
    ReadingNotificationKind.resume => bookTitle,
    ReadingNotificationKind.streak => l10n.notificationStreakTitle,
  };
  final body = switch (notification.kind) {
    ReadingNotificationKind.routine => l10n.notificationRoutineBody(
      notification.hourLabel ?? '',
      notification.goalMinutes ?? 0,
    ),
    ReadingNotificationKind.goalRemaining => l10n.notificationGoalRemainingBody(
      notification.minutesLeft ?? 0,
    ),
    ReadingNotificationKind.goalMet => l10n.notificationGoalMetBody(
      notification.goalMinutes ?? 0,
    ),
    ReadingNotificationKind.resume => _resumeBody(
      l10n,
      title: bookTitle,
      chapter: notification.chapter,
      section: notification.section,
    ),
    ReadingNotificationKind.streak => l10n.notificationStreakBody(
      notification.streakDays ?? 0,
    ),
  };
  return LocalNotificationMessage(
    id: notification.id,
    title: title,
    body: body,
    location: notification.location,
  );
}

String _resumeBody(
  AppLocalizations l10n, {
  required String title,
  required int? chapter,
  required String? section,
}) {
  if (chapter != null) {
    return l10n.notificationResumeChapterBody(chapter, title);
  }
  if (section != null && section != title) {
    return l10n.notificationResumeSectionBody(section, title);
  }
  return l10n.notificationResumeBookBody(title);
}

String _shownTitle(String? title, AppLocalizations l10n) {
  final trimmed = title?.trim() ?? '';
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

NotificationBook? _bookReadOn(
  List<NotificationSession> sessions,
  List<NotificationBook> books,
  DateTime day,
) {
  NotificationSession? latest;
  for (final session in sessions) {
    if (session.engagedSeconds <= 0) continue;
    if (!_sameDay(session.startedAt, day)) continue;
    if (latest == null || session.endedAt.isAfter(latest.endedAt)) {
      latest = session;
    }
  }
  if (latest == null) return null;
  for (final book in books) {
    if (book.id == latest.bookId) return book;
  }
  return null;
}

NotificationBook? _stalledBook({
  required List<NotificationBook> books,
  required List<NotificationSession> sessions,
  required DateTime now,
}) {
  final today = _localDate(now);
  NotificationBook? chosen;
  DateTime? chosenAt;
  for (final book in books) {
    if (book.progress <= startedBookProgress) continue;
    if (book.progress >= unfinishedBookProgress) continue;
    DateTime? lastRead;
    for (final session in sessions) {
      if (session.bookId != book.id || session.engagedSeconds <= 0) continue;
      if (lastRead == null || session.endedAt.isAfter(lastRead)) {
        lastRead = session.endedAt;
      }
    }
    if (lastRead == null) continue;
    final days = _calendarDaysBetween(_localDate(lastRead), today);
    if (days < stalledReadingDays) continue;
    if (chosenAt == null || lastRead.isAfter(chosenAt)) {
      chosen = book;
      chosenAt = lastRead;
    }
  }
  return chosen;
}

DateTime _localDate(DateTime instant) {
  final local = instant.toLocal();
  return DateTime(local.year, local.month, local.day);
}

bool _sameDay(DateTime left, DateTime right) {
  return _localDate(left) == _localDate(right);
}

int _calendarDaysBetween(DateTime start, DateTime day) {
  final first = DateTime.utc(start.year, start.month, start.day);
  final second = DateTime.utc(day.year, day.month, day.day);
  return second.difference(first).inDays;
}
