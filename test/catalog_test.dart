import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

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
          'portada_url':
              'https://storage.googleapis.com/epub_reader/catalogo/portadas/ab12.png',
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
          'descarga_url':
              'https://storage.googleapis.com/epub_reader/clasicos/la-odisea.epub',
          'tamano': 812004,
        },
      ],
    });

    expect(catalog.books, hasLength(2));
    expect(catalog.books.first.title, 'Don Quijote de la Mancha');
    expect(catalog.books.first.authors, 'Miguel de Cervantes');
    expect(catalog.books.last.coverUrl, isNull);
    expect(catalog.generatedAt, DateTime.parse('2026-09-24T05:10:00+00:00'));

    final restored = Catalog.fromJson(catalog.toJson());
    expect(restored.generatedAt, catalog.generatedAt);
    expect(restored.urlsExpireAt, DateTime.parse('2026-09-24T06:10:00+00:00'));
    expect(restored.books.first.title, catalog.books.first.title);
    expect(restored.books.first.downloadUrl, catalog.books.first.downloadUrl);
    expect(restored.books.last.coverUrl, isNull);
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
}
