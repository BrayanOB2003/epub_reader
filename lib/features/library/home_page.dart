import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
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
    setState(() => _importing = true);
    try {
      final outcome = await ref.read(epubImporterProvider).pickAndImport();
      if (outcome == ImportOutcome.alreadyInLibrary) {
        _showMessage('Este libro ya está en la biblioteca.');
      }
    } on EpubFormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo importar el EPUB.');
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Quitar «${book.title}» de la biblioteca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(bookRepositoryProvider).delete(book);
    } catch (_) {
      _showMessage('No se pudo eliminar el libro.');
    }
  }

  Future<void> _read(int bookId) async {
    if (!mounted) return;
    await context.push('/read/$bookId');
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
              'No se pudo cargar la biblioteca.\n$error',
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
        ScheduleHeader(title: 'Biblioteca', date: DateTime.now()),
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
                      title: book.title,
                      subtitle: book.author,
                      cover: book.coverBytes,
                      trailing: (book.progress * 100).round() == 0
                          ? 'Sin empezar'
                          : '${(book.progress * 100).round()} %',
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todavía no hay libros',
            style: programTitle(colors.ink, size: 36),
          ),
          const SizedBox(height: 8),
          Text(
            'Un EPUB de este dispositivo',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colors.muted),
          ),
          const Spacer(),
          ScheduleAction(
            label: importing ? 'Importando' : 'Importar',
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
                importing ? 'Importando' : 'Importar',
                style: programTitle(colors.station, size: 22),
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
    final title = book?.title ?? 'Todavía no hay libros';
    final minutes = todaySeconds ~/ 60;
    final met =
        goalMinutes != null &&
        todaySeconds >= goalMinutes! * 60 &&
        todaySeconds > 0;
    final minuteLabel = goalMinutes == null
        ? '$minutes min'
        : '$minutes / $goalMinutes';

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
                        period.label,
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
                      title: book!.title,
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
                          size: book == null ? 36 : 44,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (book == null)
                        Text(
                          'Un EPUB de este dispositivo',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.onStationMuted),
                        )
                      else if (book!.author != null)
                        Text(
                          book!.author!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.onStationMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onStationMuted,
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Eliminar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _MinuteField(label: minuteLabel, met: met),
            const SizedBox(height: 16),
            if (book == null)
              ScheduleAction(
                label: importing ? 'Importando' : 'Importar',
                onPressed: importing ? null : onImport,
                onAir: true,
              )
            else
              ScheduleAction(label: 'Leer', onPressed: onRead, onAir: true),
          ],
        ),
      ),
    );
  }
}

class _MinuteField extends StatelessWidget {
  const _MinuteField({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final background = met ? colors.onStation : Colors.transparent;
    final foreground = met ? colors.station : colors.onStation;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: colors.onStationMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, style: programTitle(foreground, size: 28)),
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
