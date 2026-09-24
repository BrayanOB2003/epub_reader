import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/core/reading/readium_reading_engine.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/discover/data/catalog_client.dart';
import 'package:epub_reader/features/discover/data/catalog_env.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final epubImporterProvider = Provider<EpubImporter>((ref) {
  return EpubImporter(ref.watch(bookRepositoryProvider));
});

final readingEngineProvider = Provider<ReadiumReadingEngine>((ref) {
  return ReadiumReadingEngine();
});

final catalogClientProvider = FutureProvider<CatalogClient>((ref) async {
  final apiKey = await loadCatalogApiKey();
  final client = CatalogClient(apiKey: apiKey);
  ref.onDispose(client.close);
  return client;
});

final catalogProvider = FutureProvider<Catalog>((ref) async {
  final client = await ref.watch(catalogClientProvider.future);
  return client.fetch();
});
