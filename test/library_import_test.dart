import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('stores the cover on the library row and skips a second import', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = await Directory.systemTemp.createTemp('epub_reader_test');
    addTearDown(() async {
      await database.close();
      if (documents.existsSync()) await documents.delete(recursive: true);
    });

    final importer = EpubImporter(BookRepository(database), documentsDirectory: () async => documents);
    final cover = Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xD9]);
    final bytes = _sampleEpub(cover);

    expect(await importer.importBytes(bytes, fallbackTitle: 'Libro'), ImportOutcome.imported);
    expect(await importer.importBytes(bytes, fallbackTitle: 'Libro'), ImportOutcome.alreadyInLibrary);

    final books = await database.select(database.books).get();
    expect(books, hasLength(1));
    expect(books.single.title, 'El hábito');
    expect(books.single.coverBytes, cover);
    expect(books.single.contentHash, isNotNull);
  });

  test('fills the cover of a book imported before covers were stored in the row', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = await Directory.systemTemp.createTemp('epub_reader_legacy');
    addTearDown(() async {
      await database.close();
      if (documents.existsSync()) await documents.delete(recursive: true);
    });

    final cover = Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xD9]);
    final bytes = _sampleEpub(cover);
    final epubFile = File(p.join(documents.path, 'legacy.epub'));
    await epubFile.writeAsBytes(bytes);
    await database.into(database.books).insert(BooksCompanion.insert(title: 'El hábito', filePath: epubFile.path, addedAt: DateTime.now()));

    final importer = EpubImporter(BookRepository(database), documentsDirectory: () async => documents);
    expect(await importer.importBytes(bytes, fallbackTitle: 'Libro'), ImportOutcome.alreadyInLibrary);

    final books = await database.select(database.books).get();
    expect(books, hasLength(1));
    expect(books.single.coverBytes, cover);
    expect(books.single.contentHash, isNotNull);
  });
}

Uint8List _sampleEpub(Uint8List cover) {
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(
      ArchiveFile.string(
        'META-INF/container.xml',
        '''
<?xml version="1.0"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/content.opf',
        '''
<package xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier>urn:uuid:habit-1</dc:identifier>
    <dc:title>El hábito</dc:title>
    <dc:creator>Ada Lovelace</dc:creator>
  </metadata>
  <manifest>
    <item id="cover-image" href="images/cover.jpg" media-type="image/jpeg" properties="cover-image"/>
  </manifest>
</package>
''',
      ),
    )
    ..addFile(ArchiveFile('OEBPS/images/cover.jpg', cover.length, cover));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
