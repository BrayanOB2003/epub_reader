import 'dart:io';
import 'dart:typed_data';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importing ? null : _import,
        icon: _importing
            ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.file_upload_outlined),
        label: Text(_importing ? 'Importando' : 'Importar'),
      ),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar la biblioteca.\n$error', textAlign: TextAlign.center)),
        data: (items) {
          if (items.isEmpty) return const _EmptyLibrary();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BookTile(book: items[index]),
          );
        },
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Todavía no hay libros', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Importa un EPUB para empezar a leer.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (book.progress * 100).round();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/read/${book.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Cover(bytes: book.coverBytes, path: book.coverPath, title: book.title),
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
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: book.progress.clamp(0, 1)),
                    const SizedBox(height: 6),
                    Text(percent == 0 ? 'Sin empezar' : '$percent %', style: theme.textTheme.labelMedium),
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

class _Cover extends StatelessWidget {
  const _Cover({required this.bytes, required this.path, required this.title});

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
