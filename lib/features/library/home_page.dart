import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _importing = false;

  Future<void> _import() async {
    if (_importing) return;
    final l10n = AppLocalizations.of(context);
    final analytics = ref.read(appAnalyticsProvider);
    setState(() => _importing = true);
    try {
      final outcome = await ref
          .read(epubImporterProvider)
          .pickAndImport(dialogTitle: l10n.importEpub, untitled: l10n.untitled);
      if (outcome == ImportOutcome.imported) {
        await analytics.logBookAdded(
          source: bookSourceImport,
          result: bookResultImported,
        );
      } else if (outcome == ImportOutcome.alreadyInLibrary) {
        await analytics.logBookAdded(
          source: bookSourceImport,
          result: bookResultAlreadyInLibrary,
        );
      }
      if (!mounted) return;
      if (outcome == ImportOutcome.alreadyInLibrary) {
        _showMessage(l10n.alreadyInLibrary);
      }
    } on EpubFormatException catch (error) {
      await analytics.logBookAdded(
        source: bookSourceImport,
        result: bookResultInvalid,
      );
      if (!mounted) return;
      _showMessage(_epubMessage(l10n, error));
    } catch (_, stack) {
      await analytics.recordUnexpected('import_failed', stack);
      if (!mounted) return;
      _showMessage(l10n.importFailed);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(Book book) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBook),
        content: Text(l10n.removeBook(_shownTitle(book.title, l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(bookRepositoryProvider).delete(book);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.deleteFailed);
    }
  }

  Future<void> _read(int bookId) async {
    if (!mounted) return;
    await context.push(readingRoute(bookId, readingSourceLibrary));
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final profile = ref.watch(readerProfileProvider).asData?.value;
    final sessions =
        ref.watch(readingSessionsProvider).asData?.value ?? const [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: books.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              AppLocalizations.of(context).libraryLoadFailed('$error'),
              textAlign: TextAlign.center,
            ),
          ),
          data: (items) => _Schedule(
            books: items,
            sessions: sessions,
            profile: profile,
            importing: _importing,
            onImport: _import,
            onRead: _read,
            onDelete: _delete,
          ),
        ),
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({
    required this.books,
    required this.sessions,
    required this.profile,
    required this.importing,
    required this.onImport,
    required this.onRead,
    required this.onDelete,
  });

  final List<Book> books;
  final List<ReadingSession> sessions;
  final ReaderProfile? profile;
  final bool importing;
  final VoidCallback onImport;
  final ValueChanged<int> onRead;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routine = profile == null
        ? null
        : ReadingRoutine.byId(profile!.routine);
    final featured = _onAirBook(books, sessions);
    final shelf = [
      for (final book in books)
        if (routine == null || featured == null || book.id != featured.id) book,
    ];
    final todaySeconds = _secondsToday(sessions, DateTime.now());
    final goal = profile?.dailyGoalMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleHeader(title: l10n.library, date: DateTime.now()),
        const ScheduleRule(),
        if (routine != null)
          _LiveBand(
            period: routine,
            book: featured,
            todaySeconds: todaySeconds,
            goalMinutes: goal,
            hour: profile?.routineHour,
            importing: importing,
            onImport: onImport,
            onRead: featured == null ? null : () => onRead(featured.id),
            onDelete: featured == null ? null : () => onDelete(featured),
          ),
        if (books.isEmpty && routine == null)
          Expanded(
            child: _EmptyLibrary(importing: importing, onImport: onImport),
          )
        else if (books.isNotEmpty) ...[
          _ImportLine(importing: importing, onImport: onImport),
          const ScheduleRule(),
          if (shelf.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final book in shelf)
                    ScheduleListing(
                      key: ValueKey(book.id),
                      title: _shownTitle(book.title, l10n),
                      subtitle: book.author,
                      cover: book.coverBytes,
                      progress: book.progress,
                      trailing: _progressLabel(l10n, book.progress),
                      onTap: () => onRead(book.id),
                      onDelete: () => onDelete(book),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.importing, required this.onImport});

  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.noBooksYet, style: programTitle(colors.ink, size: 36)),
          const SizedBox(height: 8),
          Text(
            l10n.epubOnDevice,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colors.muted),
          ),
          const Spacer(),
          ScheduleAction(
            label: importing ? l10n.importing : l10n.import,
            onPressed: importing ? null : onImport,
          ),
        ],
      ),
    );
  }
}

class _ImportLine extends StatelessWidget {
  const _ImportLine({required this.importing, required this.onImport});

  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: importing ? null : onImport,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                importing ? l10n.importing : l10n.import,
                style: _controlLabel(
                  context,
                  importing ? colors.muted : colors.station,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBand extends StatelessWidget {
  const _LiveBand({
    required this.period,
    required this.book,
    required this.todaySeconds,
    required this.goalMinutes,
    required this.hour,
    required this.importing,
    required this.onImport,
    required this.onRead,
    required this.onDelete,
  });

  final ReadingRoutine period;
  final Book? book;
  final int todaySeconds;
  final int? goalMinutes;
  final int? hour;
  final bool importing;
  final VoidCallback onImport;
  final VoidCallback? onRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    final title = book == null
        ? l10n.noBooksYet
        : _shownTitle(book!.title, l10n);
    final minutes = todaySeconds ~/ 60;
    final met =
        goalMinutes != null &&
        todaySeconds >= goalMinutes! * 60 &&
        todaySeconds > 0;
    final minuteLabel = goalMinutes == null
        ? l10n.minutesShort(minutes)
        : l10n.minutesOfGoal(minutes, goalMinutes!);

    return ColoredBox(
      color: colors.station,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hour == null ? _span(period) : readingHourLabel(hour!),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onStationMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        period.label(AppLocalizations.of(context)),
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: colors.onStation),
                      ),
                    ],
                  ),
                ),
                if (book != null) ...[
                  if (book!.coverBytes != null && book!.coverBytes!.isNotEmpty)
                    ScheduleCover(
                      bytes: book!.coverBytes!,
                      width: 72,
                      height: 108,
                      borderColor: colors.onStationMuted,
                    )
                  else
                    ScheduleCoverPlaceholder(
                      width: 72,
                      height: 108,
                      title: _shownTitle(book!.title, l10n),
                      borderColor: colors.onStationMuted,
                      onAir: true,
                    ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: programTitle(
                          colors.onStation,
                          size: book == null ? 36 : 28,
                        ),
                        maxLines: book == null ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (book == null)
                        Text(
                          l10n.epubOnDevice,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.onStationMuted),
                        )
                      else ...[
                        if (book!.author != null) ...[
                          Text(
                            book!.author!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: colors.onStationMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ScheduleProgress(
                                value: book!.progress,
                                onAir: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _progressLabel(l10n, book!.progress),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: colors.onStationMuted),
                            ),
                          ],
                        ),
                        if (onDelete != null)
                          TextButton(
                            onPressed: onDelete,
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onStationMuted,
                              minimumSize: const Size(44, 44),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(l10n.delete),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MinuteField(
              caption: met ? l10n.goalLabel : l10n.today,
              label: minuteLabel,
              met: met,
            ),
            const SizedBox(height: 16),
            if (book == null)
              ScheduleAction(
                label: importing ? l10n.importing : l10n.import,
                onPressed: importing ? null : onImport,
                onAir: true,
              )
            else
              ScheduleAction(label: l10n.read, onPressed: onRead, onAir: true),
          ],
        ),
      ),
    );
  }
}

class _MinuteField extends StatelessWidget {
  const _MinuteField({
    required this.caption,
    required this.label,
    required this.met,
  });

  final String caption;
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final background = met ? colors.onStation : Colors.transparent;
    final foreground = met ? colors.station : colors.onStation;
    final captionColor = met ? colors.station : colors.onStationMuted;
    return Semantics(
      excludeSemantics: true,
      label: caption,
      value: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: colors.onStationMuted),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: captionColor),
              ),
              const SizedBox(height: 4),
              Text(label, style: programTitle(foreground, size: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

String _span(ReadingRoutine period) {
  final start = period.firstHour.toString().padLeft(2, '0');
  final end = period.lastHour.toString().padLeft(2, '0');
  return '$start–$end';
}

Book? _onAirBook(List<Book> books, List<ReadingSession> sessions) {
  if (books.isEmpty) return null;
  final byId = {for (final book in books) book.id: book};
  for (final session in sessions) {
    final book = byId[session.bookId];
    if (book != null) return book;
  }
  return books.first;
}

int _secondsToday(List<ReadingSession> sessions, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var total = 0;
  for (final session in sessions) {
    final local = session.startedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) total += session.engagedSeconds;
  }
  return total;
}

String _shownTitle(String title, AppLocalizations l10n) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? l10n.untitled : trimmed;
}

String _progressLabel(AppLocalizations l10n, double progress) {
  final percent = (progress * 100).round();
  if (percent <= 0) return l10n.notStarted;
  return '$percent %';
}

TextStyle _controlLabel(BuildContext context, Color color) {
  final ios = Theme.of(context).platform == TargetPlatform.iOS;
  return TextStyle(
    color: color,
    fontWeight: FontWeight.w600,
    fontSize: ios ? 17 : 14,
    letterSpacing: ios ? -0.41 : 0.1,
  );
}

String _epubMessage(AppLocalizations l10n, EpubFormatException error) {
  return switch (error.failure) {
    EpubFormatFailure.notEpub => l10n.notAnEpub,
    EpubFormatFailure.missingRoot => l10n.epubMissingRoot,
    EpubFormatFailure.missingContent => l10n.epubMissingContent,
  };
}
