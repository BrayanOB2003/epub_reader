import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads title, author and cover from an EPUB package', () {
    final cover = Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0x00]);
    final bytes = _epub(
      opf: '''
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier>urn:uuid:habit-1</dc:identifier>
    <dc:title>El hábito</dc:title>
    <dc:creator>Ada Lovelace</dc:creator>
    <meta name="cover" content="cover-image"/>
  </metadata>
  <manifest>
    <item id="cover-image" href="images/cover.jpg" media-type="image/jpeg" properties="cover-image"/>
  </manifest>
</package>
''',
      cover: cover,
    );

    final metadata = readEpubMetadata(bytes);

    expect(metadata.title, 'El hábito');
    expect(metadata.author, 'Ada Lovelace');
    expect(metadata.bookUid, 'urn:uuid:habit-1');
    expect(metadata.coverBytes, cover);
    expect(metadata.coverExtension, 'jpg');
  });

  test('rejects a file that is not an EPUB', () {
    final archive = Archive()
      ..addFile(ArchiveFile.string('readme.txt', 'hola'));
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive));

    expect(() => readEpubMetadata(bytes), throwsA(isA<EpubFormatException>()));
  });
}

Uint8List _epub({required String opf, Uint8List? cover}) {
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(
      ArchiveFile.string('META-INF/container.xml', '''
<?xml version="1.0"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
'''),
    )
    ..addFile(ArchiveFile.string('OEBPS/content.opf', opf));
  if (cover != null) {
    archive.addFile(ArchiveFile('OEBPS/images/cover.jpg', cover.length, cover));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
