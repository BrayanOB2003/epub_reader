import 'dart:convert';

import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/reading_time.dart';

String encodeMonthReport(MonthReadingReport report) {
  return jsonEncode({
    'engagedSeconds': report.engagedSeconds,
    'metDays': report.metDays,
    'plannedDays': report.plannedDays,
    'minuteDeltaSeconds': report.minuteDeltaSeconds,
    'comparedYear': report.comparedMonth?.year,
    'comparedMonth': report.comparedMonth?.month,
    'archetype': _archetypeJson(report.archetype),
    'quote': report.quote == null
        ? null
        : {
            'passage': report.quote!.passage,
            'bookTitle': report.quote!.bookTitle,
          },
    'books': [for (final book in report.books) _bookJson(book)],
  });
}

MonthReadingReport decodeMonthReport(
  String document, {
  required DateTime month,
}) {
  final decoded = jsonDecode(document);
  if (decoded is! Map) {
    throw const FormatException('El resumen del mes no se puede leer.');
  }
  final comparedYear = _int(decoded['comparedYear']);
  final comparedMonth = _int(decoded['comparedMonth']);
  return MonthReadingReport(
    month: DateTime(month.year, month.month),
    closed: true,
    engagedSeconds: _int(decoded['engagedSeconds']) ?? 0,
    metDays: _int(decoded['metDays']),
    plannedDays: _int(decoded['plannedDays']),
    minuteDeltaSeconds: _int(decoded['minuteDeltaSeconds']),
    comparedMonth: comparedYear == null || comparedMonth == null
        ? null
        : DateTime(comparedYear, comparedMonth),
    books: _books(decoded['books']),
    archetype: _archetype(decoded['archetype']),
    quote: _quote(decoded['quote']),
  );
}

/// Keeps the frozen line and attaches the cover when the book is still here.
MonthReadingReport monthReportInLibrary(
  MonthReadingReport report,
  Iterable<Book> books,
) {
  final byId = {for (final book in books) book.id: book};
  return MonthReadingReport(
    month: report.month,
    closed: report.closed,
    engagedSeconds: report.engagedSeconds,
    metDays: report.metDays,
    plannedDays: report.plannedDays,
    minuteDeltaSeconds: report.minuteDeltaSeconds,
    comparedMonth: report.comparedMonth,
    archetype: report.archetype,
    quote: report.quote,
    books: [
      for (final line in report.books)
        MonthBookLine(
          bookId: line.bookId,
          title: line.title,
          engagedSeconds: line.engagedSeconds,
          progress: line.progress,
          finished: line.finished,
          horizon: line.horizon,
          coverBytes: byId[line.bookId]?.coverBytes,
          available: byId.containsKey(line.bookId),
        ),
    ],
  );
}

Map<String, Object?>? _archetypeJson(MonthArchetypeReport? report) {
  if (report == null) return null;
  return switch (report.evidence) {
    MethodicalEvidence(:final onTime, :final sessions, :final hour) => {
      'kind': 'methodical',
      'onTime': onTime,
      'sessions': sessions,
      'hour': hour,
    },
    AntEvidence(:final metDays, :final plannedDays) => {
      'kind': 'ant',
      'metDays': metDays,
      'plannedDays': plannedDays,
    },
    MarathonerEvidence(:final averageSeconds) => {
      'kind': 'marathoner',
      'averageSeconds': averageSeconds,
    },
    HunterEvidence(:final sessionsWithQuotes, :final sessions) => {
      'kind': 'hunter',
      'sessionsWithQuotes': sessionsWithQuotes,
      'sessions': sessions,
    },
    BandEvidence(:final percent) => {
      'kind': report.kind.name,
      'percent': percent,
    },
    NomadEvidence() => {'kind': 'nomad'},
  };
}

MonthArchetypeReport? _archetype(Object? value) {
  if (value is! Map) return null;
  final kind = value['kind'];
  final evidence = switch (kind) {
    'methodical' => MethodicalEvidence(
      onTime: _int(value['onTime']) ?? 0,
      sessions: _int(value['sessions']) ?? 0,
      hour: _int(value['hour']) ?? 0,
    ),
    'ant' => AntEvidence(
      metDays: _int(value['metDays']) ?? 0,
      plannedDays: _int(value['plannedDays']) ?? 0,
    ),
    'marathoner' => MarathonerEvidence(
      averageSeconds: _int(value['averageSeconds']) ?? 0,
    ),
    'hunter' => HunterEvidence(
      sessionsWithQuotes: _int(value['sessionsWithQuotes']) ?? 0,
      sessions: _int(value['sessions']) ?? 0,
    ),
    'earlyRiser' ||
    'afternoon' ||
    'nightOwl' => BandEvidence(percent: _int(value['percent']) ?? 0),
    'nomad' => const NomadEvidence(),
    _ => null,
  };
  if (evidence == null) return null;
  final archetype = switch (kind) {
    'methodical' => MonthArchetype.methodical,
    'ant' => MonthArchetype.ant,
    'marathoner' => MonthArchetype.marathoner,
    'hunter' => MonthArchetype.ideaHunter,
    'earlyRiser' => MonthArchetype.earlyRiser,
    'afternoon' => MonthArchetype.afternoon,
    'nightOwl' => MonthArchetype.nightOwl,
    'nomad' => MonthArchetype.nomad,
    _ => null,
  };
  if (archetype == null) return null;
  return MonthArchetypeReport(kind: archetype, evidence: evidence);
}

Map<String, Object?> _bookJson(MonthBookLine book) {
  return {
    'bookId': book.bookId,
    'title': book.title,
    'engagedSeconds': book.engagedSeconds,
    'progress': book.progress,
    'finished': book.finished,
    'horizon': _horizonJson(book.horizon),
  };
}

List<MonthBookLine> _books(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map)
        MonthBookLine(
          bookId: _int(item['bookId']) ?? 0,
          title: item['title'] is String ? item['title'] as String : '',
          engagedSeconds: _int(item['engagedSeconds']) ?? 0,
          progress: item['progress'] is num
              ? (item['progress'] as num).toDouble()
              : 0,
          finished: item['finished'] == true,
          horizon: _horizon(item['horizon']),
        ),
  ];
}

Map<String, Object?>? _horizonJson(ReadingHorizon? horizon) {
  if (horizon == null) return null;
  return {'kind': horizon.kind.name, 'count': horizon.count};
}

ReadingHorizon? _horizon(Object? value) {
  if (value is! Map) return null;
  final count = _int(value['count']);
  return switch (value['kind']) {
    'underAWeek' => const ReadingHorizon.underAWeek(),
    'weeks' when count != null => ReadingHorizon.weeks(count),
    'sittings' when count != null => ReadingHorizon.sittings(count),
    _ => null,
  };
}

MonthQuoteLine? _quote(Object? value) {
  if (value is! Map) return null;
  final passage = value['passage'];
  if (passage is! String || passage.trim().isEmpty) return null;
  final title = value['bookTitle'];
  return MonthQuoteLine(
    passage: passage,
    bookTitle: title is String ? title : '',
  );
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}
