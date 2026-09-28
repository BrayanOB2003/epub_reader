import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
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
      body: SafeArea(
        bottom: false,
        child: catalog.when(
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
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: ScheduleHeader(title: 'Descubrimiento'),
                ),
                const SliverToBoxAdapter(child: ScheduleRule()),
                SliverList.builder(
                  itemCount: data.books.length,
                  itemBuilder: (context, index) {
                    final book = data.books[index];
                    final inLibrary =
                        book.identifier != null &&
                        savedIds.contains(book.identifier);
                    final downloading = _downloadingId == book.id;
                    return ScheduleListing(
                      title: book.title,
                      subtitle: inLibrary
                          ? (book.authors == null
                                ? 'En tu biblioteca'
                                : '${book.authors} · En tu biblioteca')
                          : book.authors,
                      trailing: downloading
                          ? '…'
                          : (inLibrary ? 'Leer' : 'Añadir'),
                      onTap: downloading ? null : () => _open(book),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
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

