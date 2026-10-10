import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:epub_reader/features/discover/data/catalog_cache.dart'
    show catalogCacheProvider;
export 'package:epub_reader/features/discover/data/cover_cache.dart'
    show coverCacheProvider;
export 'package:epub_reader/features/discover/data/catalog_client.dart'
    show catalogClientProvider;
export 'package:epub_reader/features/discover/data/catalog_notifier.dart'
    show catalogProvider;

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(AppDatabase.openConnection());
  ref.onDispose(database.close);
  return database;
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(databaseProvider));
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider).watchBooks();
});

final readingSessionsProvider = StreamProvider<List<ReadingSession>>((ref) {
  return ref.watch(bookRepositoryProvider).watchReadingSessions();
});

final savedQuotesProvider = StreamProvider<List<ReadingQuote>>((ref) {
  return ref.watch(bookRepositoryProvider).watchQuotes();
});

final epubImporterProvider = Provider<EpubImporter>((ref) {
  return EpubImporter(ref.watch(bookRepositoryProvider));
});

final readingEngineProvider = Provider<ReadiumReadingEngine>((ref) {
  return ReadiumReadingEngine();
});
