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
  var _opening = false;

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!reduce) {
      setState(() => _opening = true);
      await Future<void>.delayed(const Duration(milliseconds: 220));
    }
    if (!mounted) return;
    await context.push('/read/$bookId');
    if (!mounted) return;
    if (_opening) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final profile = ref.watch(readerProfileProvider).asData?.value;
    final sessions = ref.watch(readingSessionsProvider).asData?.value ?? const [];

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
            opening: _opening,
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
    required this.opening,
    required this.onImport,
    required this.onRead,
    required this.onDelete,
  });

  final List<Book> books;
  final List<ReadingSession> sessions;
  final ReaderProfile? profile;
  final bool importing;
  final bool opening;
  final VoidCallback onImport;
  final ValueChanged<int> onRead;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    final routine = profile == null ? null : ReadingRoutine.byId(profile!.routine);
    final featured = _onAirBook(books, sessions);
    final others = [
      for (final book in books)
        if (featured == null || book.id != featured.id) book,
    ];
    final todaySeconds = _secondsToday(sessions, DateTime.now());
    final goal = profile?.dailyGoalMinutes;
    final expandLive = routine != null && opening;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleHeader(title: 'Biblioteca', date: DateTime.now()),
        const ScheduleRule(),
        for (final period in ReadingRoutine.values)
          _band(
            period: period,
            live: routine == period,
            featured: featured,
            todaySeconds: todaySeconds,
            goal: goal,
            hour: profile?.routineHour,
            expand: expandLive && routine == period,
          ),
        if (routine == null)
          Expanded(
            child: _Unscheduled(
              books: books,
              importing: importing,
              onImport: onImport,
              onRead: onRead,
              onDelete: onDelete,
            ),
          )
        else if (featured != null && !opening)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final book in others)
                  ScheduleListing(
                    key: ValueKey(book.id),
                    title: book.title,
                    subtitle: book.author,
                    trailing: (book.progress * 100).round() == 0
                        ? 'Sin empezar'
                        : '${(book.progress * 100).round()} %',
                    onTap: () => onRead(book.id),
                  ),
                ScheduleListing(
                  title: importing ? 'Importando' : 'Importar',
                  subtitle: 'Un EPUB de este dispositivo',
                  onTap: importing ? null : onImport,
                ),
                ScheduleListing(
                  title: 'Eliminar',
                  subtitle: featured.title,
                  onTap: () => onDelete(featured),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _band({
    required ReadingRoutine period,
    required bool live,
    required Book? featured,
    required int todaySeconds,
    required int? goal,
    required int? hour,
    required bool expand,
  }) {
    if (!live) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: opening ? 0 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _OffAirBand(period: period),
            ),
          ),
          const ScheduleRule(),
        ],
      );
    }
    final band = _LiveBand(
      period: period,
      book: featured,
      todaySeconds: todaySeconds,
      goalMinutes: goal,
      hour: hour,
      importing: importing,
      expand: expand,
      onImport: onImport,
      onRead: featured == null ? null : () => onRead(featured.id),
    );
    if (expand) return Expanded(child: band);
    return band;
  }
}

class _Unscheduled extends StatelessWidget {
  const _Unscheduled({
    required this.books,
    required this.importing,
    required this.onImport,
    required this.onRead,
    required this.onDelete,
  });

  final List<Book> books;
  final bool importing;
  final VoidCallback onImport;
  final ValueChanged<int> onRead;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    if (books.isEmpty) {
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
              'Importa un EPUB para empezar a leer.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.muted,
              ),
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
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: books.length + 1,
      itemBuilder: (context, index) {
        if (index == books.length) {
          return ScheduleListing(
            title: importing ? 'Importando' : 'Importar',
            subtitle: 'Un EPUB de este dispositivo',
            onTap: importing ? null : onImport,
          );
        }
        final book = books[index];
        final percent = (book.progress * 100).round();
        return ScheduleListing(
          key: ValueKey(book.id),
          title: book.title,
          subtitle: book.author,
          trailing: percent == 0 ? 'Sin empezar' : '$percent %',
          onTap: () => onRead(book.id),
        );
      },
    );
  }
}

class _OffAirBand extends StatelessWidget {
  const _OffAirBand({required this.period});

  final ReadingRoutine period;

  @override
  Widget build(BuildContext context) {
    return ScheduleListing(
      leading: _span(period),
      title: period.label,
      subtitle: 'Fuera de aire',
      titleSize: 28,
      rule: false,
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
    required this.expand,
    required this.onImport,
    required this.onRead,
  });

  final ReadingRoutine period;
  final Book? book;
  final int todaySeconds;
  final int? goalMinutes;
  final int? hour;
  final bool importing;
  final bool expand;
  final VoidCallback onImport;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final title = book?.title ?? 'Todavía no hay libros';
    final minutes = todaySeconds ~/ 60;
    final met = goalMinutes != null && todaySeconds >= goalMinutes! * 60 && todaySeconds > 0;
    final minuteLabel = goalMinutes == null ? '$minutes min' : '$minutes / $goalMinutes';

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
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onStation,
                        ),
                      ),
                    ],
                  ),
                ),
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
                          'Importa un EPUB para empezar a leer.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.onStationMuted,
                          ),
                        )
                      else if (book!.author != null)
                        Text(
                          book!.author!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.onStationMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MinuteField(label: minuteLabel, met: met),
            if (expand) const Spacer(),
            const SizedBox(height: 16),
            if (book == null)
              ScheduleAction(
                label: importing ? 'Importando' : 'Importar',
                onPressed: importing ? null : onImport,
                onAir: true,
              )
            else
              ScheduleAction(
                label: 'Leer',
                onPressed: onRead,
                onAir: true,
              ),
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
        child: Text(
          label,
          style: programTitle(foreground, size: 28),
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
