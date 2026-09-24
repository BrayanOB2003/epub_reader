import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
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
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo añadir el libro a la biblioteca.');
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final library = ref.watch(booksProvider).value ?? const [];
    final savedIds = library
        .map((book) => book.bookUid)
        .whereType<String>()
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Descubrimiento')),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CatalogError(
          message: error is CatalogException
              ? error.message
              : 'No se pudo cargar el catálogo.',
          onRetry: () => ref.invalidate(catalogProvider),
        ),
        data: (data) {
          if (data.books.isEmpty) return const _CatalogEmpty();
          return RefreshIndicator(
            onRefresh: () async {
              try {
                await ref.read(catalogProvider.notifier).reload();
              } on CatalogException catch (error) {
                _showMessage(error.message);
              } catch (_) {
                _showMessage('No se pudo cargar el catálogo.');
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: data.books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = data.books[index];
                return _CatalogTile(
                  book: book,
                  inLibrary:
                      book.identifier != null &&
                      savedIds.contains(book.identifier),
                  downloading: _downloadingId == book.id,
                  onTap: () => _open(book),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'El catálogo está vacío',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando haya libros disponibles, aparecerán aquí.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.book,
    required this.inLibrary,
    required this.downloading,
    required this.onTap,
  });

  final CatalogBook book;
  final bool inLibrary;
  final bool downloading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: downloading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CatalogCover(url: book.coverUrl, title: book.title),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.authors != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.authors!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (inLibrary) ...[
                      const SizedBox(height: 8),
                      Text(
                        'En tu biblioteca',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (downloading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  inLibrary
                      ? Icons.menu_book_outlined
                      : Icons.download_outlined,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogCover extends StatelessWidget {
  const _CatalogCover({required this.url, required this.title});

  final String? url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = url;
    final Widget image;
    if (coverUrl != null) {
      image = Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _letter(theme, title),
      );
    } else {
      image = _letter(theme, title);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: 56, height: 84, child: image),
    );
  }

  Widget _letter(ThemeData theme, String title) {
    return ColoredBox(
      color: theme.colorScheme.secondaryContainer,
      child: Center(
        child: Text(
          title.isEmpty ? '?' : title.characters.first.toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
