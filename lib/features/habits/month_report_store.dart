import 'package:drift/drift.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/habits/month_report_document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final monthReportStoreProvider = Provider<MonthReportStore>((ref) {
  return MonthReportStore(ref.watch(databaseProvider));
});

final monthReportsProvider = StreamProvider<List<MonthReport>>((ref) {
  return ref.watch(monthReportStoreProvider).watch();
});

final readingPlanVersionsProvider = StreamProvider<List<ReadingPlanVersion>>((
  ref,
) {
  return ref.watch(monthReportStoreProvider).watchPlans();
});

class MonthReportStore {
  MonthReportStore(this._database);

  final AppDatabase _database;
  Future<void>? _closing;

  Stream<List<MonthReport>> watch() {
    final query = _database.select(_database.monthReports)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.year, mode: OrderingMode.desc),
        (table) =>
            OrderingTerm(expression: table.month, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<ReadingPlanVersion>> watchPlans() {
    final query = _database.select(_database.readingPlanVersions)
      ..orderBy([
        (table) => OrderingTerm(expression: table.effectiveAt),
        (table) => OrderingTerm(expression: table.id),
      ]);
    return query.watch();
  }

  /// Writes each finished month that has reading and no record yet.
  ///
  /// A month already stored is left as it was. The month in progress is not
  /// written.
  Future<void> closeElapsed({
    required Iterable<ReadingSession> sessions,
    required Iterable<Book> books,
    required Iterable<MonthQuoteInput> quotes,
    required Iterable<MonthPlanVersion> plans,
    required DateTime now,
  }) {
    return _closing ??= _write(
      sessions: sessions,
      books: books,
      quotes: quotes,
      plans: plans,
      now: now,
    ).whenComplete(() => _closing = null);
  }

  Future<void> _write({
    required Iterable<ReadingSession> sessions,
    required Iterable<Book> books,
    required Iterable<MonthQuoteInput> quotes,
    required Iterable<MonthPlanVersion> plans,
    required DateTime now,
  }) async {
    final current = readingMonthOf(now);
    DateTime? earliest;
    for (final session in sessions) {
      final month = readingMonthOf(session.startedAt);
      if (!month.isBefore(current)) continue;
      if (earliest == null || month.isBefore(earliest)) earliest = month;
    }
    final start = earliest;
    if (start == null) return;
    await _database.transaction(() async {
      final existing = await _database.select(_database.monthReports).get();
      final archived = <DateTime, int>{};
      for (final row in existing) {
        final month = DateTime(row.year, row.month);
        archived[month] = decodeMonthReport(
          row.document,
          month: month,
        ).engagedSeconds;
      }
      var month = start;
      while (month.isBefore(current)) {
        if (monthHasReading(sessions, month) && !archived.containsKey(month)) {
          final previous = DateTime(month.year, month.month - 1);
          final report = monthReadingReport(
            sessions: sessions,
            books: books,
            quotes: quotes,
            plans: plans,
            now: now,
            month: month,
            archivedPreviousSeconds: archived[previous],
          );
          if (report != null) {
            await _database
                .into(_database.monthReports)
                .insert(
                  MonthReportsCompanion.insert(
                    year: month.year,
                    month: month.month,
                    document: encodeMonthReport(report),
                  ),
                );
            archived[month] = report.engagedSeconds;
          }
        }
        month = DateTime(month.year, month.month + 1);
      }
    });
  }
}
