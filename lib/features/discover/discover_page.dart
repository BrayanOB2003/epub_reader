import 'dart:typed_data';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  String? _downloadingId;
  String? _language;

  Future<void> _open(CatalogBook book) async {
    if (_downloadingId != null) return;
    final identifier = book.identifier;
    if (identifier != null) {
      final saved = await ref
          .read(bookRepositoryProvider)
          .findByBookUid(identifier);
      if (!mounted) return;
      if (saved != null) {
        context.push('/read/${saved.id}');
        return;
      }
    }

    setState(() => _downloadingId = book.id);
    try {
      var catalog = await ref.read(catalogProvider.future);
      if (catalog.urlsExpired) {
        catalog = await ref.read(catalogProvider.notifier).reload();
      }
      final source =
          catalog.books.where((item) => item.id == book.id).firstOrNull ?? book;
      final client = await ref.read(catalogClientProvider.future);
      final bytes = await client.download(source.downloadUrl);
      final imported = await ref
          .read(epubImporterProvider)
          .importBytes(bytes, fallbackTitle: source.title);
      if (!mounted) return;
      context.push('/read/${imported.bookId}');
    } on CatalogException catch (error) {
      if (!mounted) return;
      _showMessage(_catalogMessage(AppLocalizations.of(context), error));
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).addFailed);
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final library = ref.watch(booksProvider).value ?? const [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _CatalogError(
            message: error is CatalogException
                ? _catalogMessage(AppLocalizations.of(context), error)
                : AppLocalizations.of(context).catalogLoadFailed,
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (data) {
            if (data.books.isEmpty) return const _CatalogEmpty();
            return RefreshIndicator(
              onRefresh: () async {
                try {
                  await ref.read(catalogProvider.notifier).reload();
                } on CatalogException catch (error) {
                  if (!context.mounted) return;
                  _showMessage(
                    _catalogMessage(AppLocalizations.of(context), error),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  _showMessage(AppLocalizations.of(context).catalogLoadFailed);
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: ScheduleHeader(title: 'Descubrimiento'),
                  ),
                  const SliverToBoxAdapter(child: ScheduleRule()),
                  ..._catalogSlivers(data.books, library),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _catalogSlivers(List<CatalogBook> books, List<Book> library) {
    final savedIds = library
        .map((book) => book.bookUid)
        .whereType<String>()
        .toSet();
    final languages = {
      for (final book in books) ?_languageFamily(book.language),
    }.toList();
    bool shown(CatalogBook book) =>
        _language == null || _languageFamily(book.language) == _language;
    final available = [
      for (final book in books)
        if (shown(book) &&
            (book.identifier == null || !savedIds.contains(book.identifier)))
          book,
    ];
    final owned = [
      for (final book in books)
        if (shown(book) &&
            book.identifier != null &&
            savedIds.contains(book.identifier))
          book,
    ];

    return [
      if (languages.length > 1)
        SliverToBoxAdapter(
          child: _LanguageRow(
            languages: languages,
            selected: _language,
            onSelect: (code) => setState(() => _language = code),
          ),
        ),
      if (available.isNotEmpty) ...[
        const SliverToBoxAdapter(child: _SectionTitle('Por añadir')),
        ..._genreSlivers(available, library),
      ],
      if (owned.isNotEmpty) ...[
        const SliverToBoxAdapter(child: _SectionTitle('En tu biblioteca')),
        SliverList.builder(
          itemCount: owned.length,
          itemBuilder: (context, index) {
            final book = owned[index];
            final downloading = _downloadingId == book.id;
            final stored = _storedCover(library, book.identifier);
            return ScheduleListing(
              title: book.title,
              subtitle: book.authors,
              caption: catalogGenreLabel(book.genres),
              cover: stored,
              coverUrl: stored == null ? book.coverUrl : null,
              trailing: downloading ? '…' : 'Leer',
              onTap: downloading ? null : () => _open(book),
            );
          },
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  List<Widget> _genreSlivers(List<CatalogBook> books, List<Book> library) {
    final grouped = groupCatalogBooks(books);
    return [
      for (final shelf in grouped.shelves) ...[
        if (shelf.genre != null)
          SliverToBoxAdapter(child: _GenreLabel(shelf.genre!)),
        SliverList.builder(
          itemCount: shelf.books.length,
          itemBuilder: (context, index) {
            final book = shelf.books[index];
            final downloading = _downloadingId == book.id;
            final stored = _storedCover(library, book.identifier);
            return ScheduleListing(
              key: ValueKey(book.id),
              title: book.title,
              subtitle: book.authors,
              caption: catalogGenreLabel(book.genres),
              cover: stored,
              coverUrl: stored == null ? book.coverUrl : null,
              coverWidth: 72,
              coverHeight: 108,
              trailing: downloading ? '…' : 'Añadir',
              onTap: downloading ? null : () => _open(book),
            );
          },
        ),
      ],
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: programTitle(ScheduleColors.of(context).ink, size: 22),
      ),
    );
  }
}

class _GenreLabel extends StatelessWidget {
  const _GenreLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: ScheduleColors.of(context).muted),
        ),
      ),
    );
  }
}

class CatalogShelf {
  const CatalogShelf({required this.genre, required this.books});

  final String? genre;
  final List<CatalogBook> books;
}

class CatalogShelves {
  const CatalogShelves({required this.shelves});

  final List<CatalogShelf> shelves;
}

const _broadGenre = 'Fiction';

/// Genres worth showing. A leading Fiction drops out when the book names
/// something more specific.
List<String> catalogGenreNames(List<String> genres) {
  final specific = [
    for (final genre in genres)
      if (genre != _broadGenre) genre,
  ];
  if (specific.isNotEmpty) return specific;
  return List<String>.from(genres);
}

String? catalogGenreLabel(List<String> genres) {
  final names = catalogGenreNames(genres);
  if (names.isEmpty) return null;
  return names.join(' · ');
}

/// Groups books still to add by their specific genre, in catalog order.
/// Books with no genre stay last.
CatalogShelves groupCatalogBooks(List<CatalogBook> books) {
  final order = <String>[];
  final byGenre = <String, List<CatalogBook>>{};
  final plain = <CatalogBook>[];
  for (final book in books) {
    final names = catalogGenreNames(book.genres);
    if (names.isEmpty) {
      plain.add(book);
      continue;
    }
    final genre = names.first;
    byGenre
        .putIfAbsent(genre, () {
          order.add(genre);
          return <CatalogBook>[];
        })
        .add(book);
  }
  return CatalogShelves(
    shelves: [
      for (final genre in order)
        CatalogShelf(genre: genre, books: byGenre[genre]!),
      if (plain.isNotEmpty) CatalogShelf(genre: null, books: plain),
    ],
  );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.languages,
    required this.selected,
    required this.onSelect,
  });

  final List<String> languages;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final choices = <(String?, String)>[
      (null, 'Todos'),
      for (final code in languages) (code, _languageName(code)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (code, label) in choices)
            _LanguageChip(
              label: label,
              selected: selected == code,
              colors: colors,
              onTap: () => onSelect(code),
            ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ScheduleColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.station : colors.paper,
            border: Border.all(color: selected ? colors.station : colors.rule),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: selected ? colors.onStation : colors.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _languageFamily(String? code) {
  if (code == null || code.isEmpty) return null;
  final lower = code.toLowerCase().replaceAll('_', '-');
  if (lower.startsWith('es') || lower.startsWith('spa')) return 'es';
  if (lower.startsWith('en') || lower.startsWith('eng')) return 'en';
  return lower;
}

String _languageName(String code) {
  return switch (code) {
    'es' => 'Español',
    'en' => 'Inglés',
    _ => code,
  };
}

String _catalogMessage(AppLocalizations l10n, CatalogException error) {
  return switch (error.failure) {
    CatalogFailure.load =>
      error.statusCode == null
          ? l10n.catalogLoadFailed
          : l10n.catalogLoadFailedStatus(error.statusCode!),
    CatalogFailure.format => l10n.catalogInvalid,
    CatalogFailure.missingUrl => l10n.missingDownload,
    CatalogFailure.download => l10n.downloadFailed(error.statusCode ?? 0),
    CatalogFailure.missingKey => l10n.missingApiKey,
  };
}

Uint8List? _storedCover(List<Book> library, String? identifier) {
  if (identifier == null) return null;
  for (final book in library) {
    final bytes = book.coverBytes;
    if (book.bookUid == identifier && bytes != null && bytes.isNotEmpty) {
      return bytes;
    }
  }
  return null;
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScheduleHeader(title: 'Descubrimiento'),
        const ScheduleRule(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El catálogo está vacío',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando haya libros disponibles, aparecerán aquí.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
