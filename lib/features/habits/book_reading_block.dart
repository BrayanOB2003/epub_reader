import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/habits/reading_time.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BookReadingBlock extends StatelessWidget {
  const BookReadingBlock({
    required this.report,
    required this.onRead,
    this.logRow = false,
    super.key,
  });

  final BookReadingReport report;
  final VoidCallback onRead;

  /// The time screen's book: cover, title, author, and one duration.
  /// Tapping it opens the same report as the books listed under Por libro.
  final bool logRow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = report.book;
    final author = book.author?.trim();
    final shownAuthor = author == null || author.isEmpty ? null : author;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScheduleRule(),
        if (logRow) const SizedBox(height: 12),
        ScheduleListing(
          title: _shownTitle(book.title, l10n),
          subtitle: shownAuthor,
          cover: book.coverBytes,
          progress: book.progress,
          trailing: formatReadingDuration(report.engagedSeconds),
          programTrailing: true,
          onTap: () => _openReport(context),
          rule: false,
        ),
      ],
    );
  }

  void _openReport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          BookReadingReportDialog(report: report, onRead: onRead),
    );
  }
}

/// The extended record, as one sheet of the log.
///
/// The cover, title, author, and mark name the book on paper. The total is
/// the only figure, and it is the live band. Time left sits under that band.
/// Pace, the horizon, and the session count each sit on their own line
/// further down, in the quiet ink. Quotes stay on the session line. Leer is
/// the station control; Cerrar stays text.
class BookReadingReportDialog extends StatelessWidget {
  const BookReadingReportDialog({
    required this.report,
    required this.onRead,
    super.key,
  });

  final BookReadingReport report;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = report.book;
    final colors = ScheduleColors.of(context);
    final title = _shownTitle(book.title, l10n);
    final author = book.author?.trim();
    final shownAuthor = author == null || author.isEmpty ? null : author;
    final body = Theme.of(context).textTheme.bodyMedium;
    final quiet = body?.copyWith(color: colors.muted);
    final detail = _reportDetail(l10n, report);
    final cover = book.coverBytes;
    final hasCover = cover != null && cover.isNotEmpty;

    return AlertDialog(
      semanticLabel: title,
      backgroundColor: colors.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: scheduleRadius(context)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasCover)
                  ScheduleCover(bytes: cover, width: 52, height: 74)
                else
                  ScheduleCoverPlaceholder(width: 52, height: 74, title: title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: programTitle(context, colors.ink, size: 22),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shownAuthor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          shownAuthor,
                          style: quiet,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      ScheduleProgress(value: book.progress),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ColoredBox(
            color: colors.station,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Text(
                formatReadingDuration(report.engagedSeconds),
                style: programTitle(
                  context,
                  typeOnStation(context),
                  size: 36,
                ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ),
          if (detail.remaining != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                detail.remaining!,
                style: body?.copyWith(color: colors.ink),
              ),
            ),
          if (detail.context.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                detail.remaining == null ? 16 : 12,
                20,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < detail.context.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                      child: Text(detail.context[i], style: quiet),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ScheduleAction(
              label: l10n.read,
              onPressed: () {
                Navigator.pop(context);
                onRead();
              },
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _ReportDetail {
  const _ReportDetail({this.remaining, this.context = const []});

  final String? remaining;
  final List<String> context;
}

_ReportDetail _reportDetail(AppLocalizations l10n, BookReadingReport report) {
  final pace = report.pace;
  final remaining = pace.remainingMinutes;
  final paceLine = pace.minutesPerTenPercent == null
      ? null
      : l10n.bookPacePerTen(
          formatReadingDuration(pace.minutesPerTenPercent! * 60),
        );
  final horizonLine = pace.horizon == null
      ? null
      : readingHorizonLabel(l10n, pace.horizon!);
  final countLine = _join([
    if (report.sessions > 0)
      report.sessions == 1
          ? l10n.bookSession
          : l10n.bookSessions(report.sessions),
    if (report.quotes > 0)
      report.quotes == 1 ? l10n.bookQuote : l10n.bookQuotes(report.quotes),
  ]);

  return _ReportDetail(
    remaining: remaining == null
        ? null
        : l10n.bookTimeLeft(formatReadingDuration(remaining * 60)),
    context: [
      if (paceLine != null) paceLine,
      if (horizonLine != null) horizonLine,
      if (countLine != null) countLine,
    ],
  );
}

String? _join(List<String> parts) {
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String _shownTitle(String title, AppLocalizations l10n) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

String readingHorizonLabel(AppLocalizations l10n, ReadingHorizon horizon) {
  final count = horizon.count;
  return switch (horizon.kind) {
    ReadingHorizonKind.underAWeek => l10n.bookUnderAWeek,
    ReadingHorizonKind.weeks =>
      count == 1 ? l10n.bookWeekLeft : l10n.bookWeeksLeft(count!),
    ReadingHorizonKind.sittings =>
      count == 1 ? l10n.bookSittingLeft : l10n.bookSittingsLeft(count!),
  };
}
