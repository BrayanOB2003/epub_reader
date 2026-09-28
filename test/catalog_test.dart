import 'package:drift/native.dart';
import 'package:epub_reader/app/providers.dart' hide catalogProvider;
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/discover/data/catalog_notifier.dart';
import 'package:epub_reader/features/discover/discover_page.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogBook _book(String title, List<String> genres) {
  return CatalogBook(
    id: title,
    title: title,
    downloadUrl: 'https://example.test/$title',
    genres: genres,
  );
}

void main() {
  test('reads a catalog response', () {
    final catalog = Catalog.fromJson({
      'generado_en': '2026-09-24T05:10:00+00:00',
      'urls_expiran_en': '2026-09-24T06:10:00+00:00',
      'libros': [
        {
          'id': 'don-quijote.epub',
          'titulo': 'Don Quijote de la Mancha',
          'autores': 'Miguel de Cervantes',
          'identificador': 'urn:uuid:6f8b2c1a-3e4d-4a9b-8c21-0d5e6f7a8b9c',
          'idioma': 'es',
          'generos': ['Fiction', ' Fiction ', 'Aventura'],
          'portada_url': 'https://storage.googleapis.com/epub_reader/catalogo/portadas/ab12.png',
          'descarga_url':
              'https://storage.googleapis.com/epub_reader/don-quijote.epub',
          'tamano': 2458132,
        },
        {
          'id': 'clasicos/la-odisea.epub',
          'titulo': 'La Odisea',
          'autores': 'Homero, Samuel Butler',
          'identificador': '978-1-234567-89-0',
          'idioma': 'es',
          'portada_url': null,
          'descarga_url': 'https://storage.googleapis.com/epub_reader/clasicos/la-odisea.epub',
          'tamano': 812004,
        },
      ],
    });

    expect(catalog.books, hasLength(2));
    expect(catalog.books.first.title, 'Don Quijote de la Mancha');
    expect(catalog.books.first.authors, 'Miguel de Cervantes');
    expect(catalog.books.first.genres, ['Fiction', 'Aventura']);
    expect(catalog.books.last.genres, isEmpty);
    expect(catalog.books.last.coverUrl, isNull);
    expect(catalog.generatedAt, DateTime.parse('2026-09-24T05:10:00+00:00'));

    final restored = Catalog.fromJson(catalog.toJson());
    expect(restored.generatedAt, catalog.generatedAt);
    expect(restored.urlsExpireAt, DateTime.parse('2026-09-24T06:10:00+00:00'));
    expect(restored.books.first.title, catalog.books.first.title);
    expect(restored.books.first.downloadUrl, catalog.books.first.downloadUrl);
    expect(restored.books.first.genres, ['Fiction', 'Aventura']);
    expect(restored.books.last.coverUrl, isNull);
  });

  test('reads genres from the catalog book', () {
    final book = CatalogBook.fromJson({
      'id': 'charles-dickens_a-tale-of-two-cities.epub',
      'titulo': 'A Tale of Two Cities',
      'autores': '',
      'identificador': 'https://standardebooks.org/ebooks/charles-dickens/a-tale-of-two-cities',
      'idioma': 'en-GB',
      'generos': ['Fiction', 12, ''],
      'portada_url': 'https://storage.googleapis.com/cover',
      'descarga_url': 'https://storage.googleapis.com/book',
      'tamano': 815013,
    });

    expect(book.authors, isNull);
    expect(book.language, 'en-GB');
    expect(book.genres, ['Fiction']);
    expect(book.size, 815013);
  });

  test('reads an empty catalog', () {
    final catalog = Catalog.fromJson({
      'generado_en': null,
      'urls_expiran_en': null,
      'libros': [],
    });

    expect(catalog.books, isEmpty);
    expect(catalog.generatedAt, isNull);
    expect(catalog.urlsExpireAt, isNull);
    expect(catalog.urlsExpired, isFalse);
  });

  test('groups a book under its specific genre', () {
    final grouped = groupCatalogBooks([
      _book('Cities', ['Fiction', 'Adventure']),
      _book('Plain', const []),
      _book('Island', ['Horror', 'Science Fiction']),
      _book('Cities again', ['Fiction']),
    ]);

    expect(grouped.shelves.map((shelf) => shelf.genre), [
      'Adventure',
      'Horror',
      'Fiction',
      null,
    ]);
    expect(grouped.shelves[0].books.single.title, 'Cities');
    expect(grouped.shelves[1].books.single.title, 'Island');
    expect(catalogGenreLabel(['Fiction', 'Horror']), 'Horror');
    expect(
      catalogGenreLabel(['Horror', 'Science Fiction']),
      'Horror · Science Fiction',
    );
    expect(catalogGenreLabel(['Fiction']), 'Fiction');
    expect(catalogGenreLabel(const []), isNull);
  });

  test('keeps a shared genre as its own label', () {
    final grouped = groupCatalogBooks([
      _book('Cities', ['Fiction']),
      _book('Plain', const []),
      _book('Other', ['Fiction']),
    ]);

    expect(grouped.shelves.map((shelf) => shelf.genre), ['Fiction', null]);
    expect(grouped.shelves.first.books.map((book) => book.title), [
      'Cities',
      'Other',
    ]);
  });

  testWidgets('discovery shows a genre label when several are present', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
          catalogProvider.overrideWith(_GenreCatalog.new),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: scheduleTheme(Brightness.light),
          home: const DiscoverPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Por añadir'), findsOneWidget);
    expect(find.text('Adventure'), findsNWidgets(2));
    expect(find.text('Horror'), findsOneWidget);
    expect(find.text('Horror · Science Fiction'), findsOneWidget);
    expect(find.text('Fiction'), findsNothing);
    expect(find.text('En tu biblioteca'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}

class _GenreCatalog extends CatalogNotifier {
  @override
  Future<Catalog> build() async {
    return Catalog(
      generatedAt: null,
      urlsExpireAt: DateTime.utc(2026, 9, 28, 8),
      books: [
        _book('Cities', ['Fiction', 'Adventure']),
        _book('Island', ['Horror', 'Science Fiction']),
      ],
    );
  }
}
