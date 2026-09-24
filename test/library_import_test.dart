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

    final repository = BookRepository(database, documentsDirectory: () async => documents);
    final importer = EpubImporter(repository, documentsDirectory: () async => documents);
    final cover = Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xD9]);
    final bytes = _sampleEpub(cover);

    expect((await importer.importBytes(bytes, fallbackTitle: 'Libro')).outcome, ImportOutcome.imported);
    expect((await importer.importBytes(bytes, fallbackTitle: 'Libro')).outcome, ImportOutcome.alreadyInLibrary);

    final books = await database.select(database.books).get();
    expect(books, hasLength(1));
    expect(books.single.title, 'El hábito');
    expect(books.single.coverBytes, cover);
    expect(books.single.contentHash, isNotNull);
    expect(p.isAbsolute(books.single.filePath), isFalse);
    expect(books.single.filePath, startsWith('books${p.separator}'));
    expect(books.single.coverPath, startsWith('covers${p.separator}'));
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

    final repository = BookRepository(database, documentsDirectory: () async => documents);
    final importer = EpubImporter(repository, documentsDirectory: () async => documents);
    expect((await importer.importBytes(bytes, fallbackTitle: 'Libro')).outcome, ImportOutcome.alreadyInLibrary);

    final books = await database.select(database.books).get();
    expect(books, hasLength(1));
    expect(books.single.coverBytes, cover);
    expect(books.single.contentHash, isNotNull);
  });

  test('removes the library row and its files', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = await Directory.systemTemp.createTemp('epub_reader_delete');
    addTearDown(() async {
      await database.close();
      if (documents.existsSync()) await documents.delete(recursive: true);
    });

    final repository = BookRepository(database, documentsDirectory: () async => documents);
    final importer = EpubImporter(repository, documentsDirectory: () async => documents);
    await importer.importBytes(_sampleEpub(Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xD9])), fallbackTitle: 'Libro');

    final book = (await database.select(database.books).get()).single;
    final epubFile = File(p.join(documents.path, book.filePath));
    final coverFile = File(p.join(documents.path, book.coverPath!));
    expect(epubFile.existsSync(), isTrue);
    expect(coverFile.existsSync(), isTrue);

    await repository.delete(book);

    expect(await database.select(database.books).get(), isEmpty);
    expect(epubFile.existsSync(), isFalse);
    expect(coverFile.existsSync(), isFalse);
  });

  test('finds a book whose stored path belongs to an old container', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final documents = await Directory.systemTemp.createTemp('epub_reader_relocate');
    addTearDown(() async {
      await database.close();
      if (documents.existsSync()) await documents.delete(recursive: true);
    });

    await Directory(p.join(documents.path, 'books')).create();
    await Directory(p.join(documents.path, 'covers')).create();
    await File(p.join(documents.path, 'books', 'sample.epub')).writeAsBytes([1, 2, 3]);
    await File(p.join(documents.path, 'covers', 'sample.jpg')).writeAsBytes([4, 5, 6]);

    const staleRoot = '/private/var/containers/Application/OLD-CONTAINER/Documents';
    final id = await database.into(database.books).insert(
      BooksCompanion.insert(
        title: 'Mudado',
        filePath: p.join(staleRoot, 'books', 'sample.epub'),
        coverPath: Value(p.join(staleRoot, 'covers', 'sample.jpg')),
        addedAt: DateTime.now(),
      ),
    );

    final repository = BookRepository(database, documentsDirectory: () async => documents);
    final book = await repository.getBook(id);

    expect(File(book!.filePath).existsSync(), isTrue);
    expect(File(book.coverPath!).existsSync(), isTrue);

    final stored = await (database.select(database.books)..where((table) => table.id.equals(id))).getSingle();
    expect(stored.filePath, p.join('books', 'sample.epub'));
    expect(stored.coverPath, p.join('covers', 'sample.jpg'));
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
