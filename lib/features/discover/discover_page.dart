import 'dart:io';
import 'dart:typed_data';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Descubrimiento')),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('No se pudo cargar el descubrimiento.\n$error', textAlign: TextAlign.center),
        ),
        data: (items) {
          final unread = items.where((book) => book.progress <= 0).toList();
          if (unread.isEmpty) {
            return _DiscoverEmpty(hasBooks: items.isNotEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: unread.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text('Para empezar', style: Theme.of(context).textTheme.titleMedium);
              }
              return _DiscoverTile(book: unread[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _DiscoverEmpty extends StatelessWidget {
  const _DiscoverEmpty({required this.hasBooks});

  final bool hasBooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              hasBooks ? 'Ya empezaste todos tus libros' : 'Todavía no hay lecturas nuevas',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasBooks
                  ? 'Cuando importes un EPUB que no hayas abierto, aparecerá aquí.'
                  : 'Importa un EPUB en Biblioteca y los que no hayas empezado se muestran aquí.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  const _DiscoverTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/read/${book.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _DiscoverCover(bytes: book.coverBytes, path: book.coverPath, title: book.title),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (book.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.author!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverCover extends StatelessWidget {
  const _DiscoverCover({required this.bytes, required this.path, required this.title});

  final Uint8List? bytes;
  final String? path;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storedCover = bytes;
    final file = path == null ? null : File(path!);
    final Widget image;
    if (storedCover != null && storedCover.isNotEmpty) {
      image = Image.memory(storedCover, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (file != null && file.existsSync()) {
      image = Image.file(file, fit: BoxFit.cover, gaplessPlayback: true);
    } else {
      image = ColoredBox(
        color: theme.colorScheme.secondaryContainer,
        child: Center(
          child: Text(
            title.isEmpty ? '?' : title.characters.first.toUpperCase(),
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: 56, height: 84, child: image),
    );
  }
}
