import 'dart:io';
import 'dart:typed_data';

import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EpubImporter {
  EpubImporter(this._repository);

  final BookRepository _repository;

  Future<bool> pickAndImport() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Importar EPUB',
      type: FileType.custom,
      allowedExtensions: const ['epub'],
    );
    if (file == null) return false;

    final bytes = await file.readAsBytes();
    final fallbackTitle = p.basenameWithoutExtension(file.name);
    final metadata = readEpubMetadata(bytes, fallbackTitle: fallbackTitle.isEmpty ? 'Sin título' : fallbackTitle);
    await _store(bytes, metadata);
    return true;
  }

  Future<void> _store(Uint8List bytes, EpubMetadata metadata) async {
    final documents = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final booksDir = Directory(p.join(documents.path, 'books'));
    await booksDir.create(recursive: true);

    final epubFile = File(p.join(booksDir.path, '$stamp.epub'));
    await epubFile.writeAsBytes(bytes, flush: true);

    String? coverPath;
    final coverBytes = metadata.coverBytes;
    if (coverBytes != null && coverBytes.isNotEmpty) {
      final coversDir = Directory(p.join(documents.path, 'covers'));
      await coversDir.create(recursive: true);
      final coverFile = File(p.join(coversDir.path, '$stamp.${metadata.coverExtension ?? 'jpg'}'));
      await coverFile.writeAsBytes(coverBytes, flush: true);
      coverPath = coverFile.path;
    }

    await _repository.insert(
      title: metadata.title,
      author: metadata.author,
      filePath: epubFile.path,
      coverPath: coverPath,
    );
  }
}
