import 'dart:async';
import 'dart:convert';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({required this.bookId, super.key});

  final int bookId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late final BookRepository _repository;
  late final ReadiumReadingEngine _engine;

  Book? _book;
  Publication? _publication;
  Locator? _latestLocator;
  StreamSubscription<Locator>? _locatorSubscription;
  Timer? _saveTimer;
  var _progress = 0.0;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = ref.read(bookRepositoryProvider);
    _engine = ref.read(readingEngineProvider);
    _open();
  }

  Future<void> _open() async {
    final book = await _repository.getBook(widget.bookId);
    if (!mounted) return;
    if (book == null) {
      setState(() {
        _loading = false;
        _error = 'Este libro ya no está en la biblioteca.';
      });
      return;
    }

    try {
      final publication = await _engine.open(book.filePath);
      _locatorSubscription = _engine.onLocator.listen(_onLocator);
      if (!mounted) {
        await _engine.close();
        return;
      }
      setState(() {
        _book = book;
        _publication = publication;
        _progress = book.progress;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _openErrorMessage(error);
      });
    }
  }

  void _onLocator(Locator locator) {
    _latestLocator = locator;
    final progression = locator.locations?.totalProgression;
    if (progression != null && mounted) {
      setState(() => _progress = progression);
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _persist);
  }

  Future<void> _persist() async {
    final locator = _latestLocator;
    if (locator == null) return;
    final progress = locator.locations?.totalProgression ?? _progress;
    await _repository.saveProgress(
      id: widget.bookId,
      locatorJson: jsonEncode(locator.toJson()),
      progress: progress,
    );
  }

  Locator? _savedLocator(Book book) {
    final raw = book.locatorJson;
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Locator.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final locator = _latestLocator;
    if (locator != null) {
      unawaited(
        _repository.saveProgress(
          id: widget.bookId,
          locatorJson: jsonEncode(locator.toJson()),
          progress: locator.locations?.totalProgression ?? _progress,
        ),
      );
    }
    unawaited(_locatorSubscription?.cancel());
    unawaited(_engine.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _book?.title ?? 'Leyendo';
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _loading ? null : _progress.clamp(0, 1)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final publication = _publication;
    final book = _book;
    if (publication == null || book == null) {
      return const Center(child: Text('No se pudo abrir el libro.'));
    }

    return ReadiumReaderWidget(publication: publication, initialLocator: _savedLocator(book));
  }
}

String _openErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('MethodNotImplemented') || text.contains('not implemented')) {
    return 'El lector funciona en iOS y Android. En el escritorio de macOS Readium no abre el EPUB.';
  }
  return 'No se pudo abrir el libro.';
}
