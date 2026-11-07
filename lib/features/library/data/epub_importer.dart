import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/library/data/book_format.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:epub_reader/features/library/data/pdf_describer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ImportOutcome { imported, alreadyInLibrary, cancelled }

class ImportResult {
  const ImportResult({required this.outcome, required this.bookId});

  final ImportOutcome outcome;
  final int bookId;
}

class EpubImporter {
  EpubImporter(
    this._repository, {
    Future<Directory> Function()? documentsDirectory,
    this.pdfDescriber,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final BookRepository _repository;
  final Future<Directory> Function() _documentsDirectory;
  final PdfDescriber? pdfDescriber;

  Future<ImportOutcome> pickAndImport({
    required String dialogTitle,
    required String untitled,
  }) async {
    final file = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['epub', 'pdf'],
    );
    if (file == null) return ImportOutcome.cancelled;

    final bytes = await file.readAsBytes();
    final fallbackTitle = p.basenameWithoutExtension(file.name);
    final result = await importBytes(
      bytes,
      fallbackTitle: fallbackTitle.isEmpty ? untitled : fallbackTitle,
    );
    return result.outcome;
  }

  Future<ImportResult> importBytes(
    Uint8List bytes, {
    required String fallbackTitle,
  }) async {
    if (looksLikePdf(bytes)) {
      return _importPdf(bytes, fallbackTitle: fallbackTitle);
    }
    final metadata = readEpubMetadata(bytes, fallbackTitle: fallbackTitle);
    final contentHash = sha256.convert(bytes).toString();
    final existing =
        await _repository.findDuplicate(
          contentHash: contentHash,
          bookUid: metadata.bookUid,
        ) ??
        await _matchLegacyBook(contentHash, metadata.bookUid);
    if (existing != null) {
      await _keepCover(existing, metadata);
      return ImportResult(
        outcome: ImportOutcome.alreadyInLibrary,
        bookId: existing.id,
      );
    }

    final bookId = await _store(bytes, metadata, contentHash);
    return ImportResult(outcome: ImportOutcome.imported, bookId: bookId);
  }

  Future<Book?> _matchLegacyBook(String contentHash, String? bookUid) async {
    final pending = await _repository.booksWithoutHash();
    for (final book in pending) {
      final file = File(book.filePath);
      if (!file.existsSync()) continue;
      final storedHash = sha256.convert(await file.readAsBytes()).toString();
      if (storedHash != contentHash) continue;
      await _repository.saveIdentity(
        id: book.id,
        contentHash: contentHash,
        bookUid: bookUid,
      );
      return book;
    }
    return null;
  }

  Future<ImportResult> _importPdf(
    Uint8List bytes, {
    required String fallbackTitle,
  }) async {
    final describer = pdfDescriber;
    if (describer == null) throw const PdfReadException();

    final contentHash = sha256.convert(bytes).toString();
    final existing = await _repository.findDuplicate(
      contentHash: contentHash,
      bookUid: null,
    );
    if (existing != null) {
      await _fillPdfCover(existing, describer, fallbackTitle);
      return ImportResult(
        outcome: ImportOutcome.alreadyInLibrary,
        bookId: existing.id,
      );
    }

    final documents = await _documentsDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final booksDir = Directory(p.join(documents.path, 'books'));
    await booksDir.create(recursive: true);
    final relativeFile = p.join('books', '$stamp.pdf');
    final file = File(p.join(documents.path, relativeFile));
    await file.writeAsBytes(bytes, flush: true);

    final described = await _describePdf(
      describer,
      file,
      fallbackTitle: fallbackTitle,
    );

    final byUid = await _repository.findDuplicate(
      contentHash: contentHash,
      bookUid: described.bookUid,
    );
    if (byUid != null) {
      await _deleteQuiet(file);
      await _storePdfCover(byUid, described.coverBytes, documents);
      return ImportResult(
        outcome: ImportOutcome.alreadyInLibrary,
        bookId: byUid.id,
      );
    }

    final coverBytes = described.coverBytes;
    String? coverPath;
    if (coverBytes != null && coverBytes.isNotEmpty) {
      coverPath = await _writeCover(documents, stamp, coverBytes, 'png');
    }
    final bookId = await _repository.insert(
      title: described.title,
      author: described.author,
      bookUid: described.bookUid,
      filePath: relativeFile,
      coverPath: coverPath,
      coverBytes: coverBytes,
      contentHash: contentHash,
    );
    return ImportResult(outcome: ImportOutcome.imported, bookId: bookId);
  }

  Future<void> _fillPdfCover(
    Book existing,
    PdfDescriber describer,
    String fallbackTitle,
  ) async {
    final stored = existing.coverBytes;
    if (stored != null && stored.isNotEmpty) return;
    if (!File(existing.filePath).existsSync()) return;
    try {
      final described = await describer.describe(
        existing.filePath,
        fallbackTitle: fallbackTitle,
      );
      final documents = await _documentsDirectory();
      await _storePdfCover(existing, described.coverBytes, documents);
    } catch (_) {}
  }

  Future<void> _storePdfCover(
    Book book,
    Uint8List? coverBytes,
    Directory documents,
  ) async {
    if (coverBytes == null || coverBytes.isEmpty) return;
    final stored = book.coverBytes;
    if (stored != null && stored.isNotEmpty) return;
    final coverPath = await _writeCover(documents, book.id, coverBytes, 'png');
    await _repository.saveCover(
      id: book.id,
      coverBytes: coverBytes,
      coverPath: coverPath,
    );
  }

  Future<PdfDescription> _describePdf(
    PdfDescriber describer,
    File file, {
    required String fallbackTitle,
  }) async {
    try {
      return await describer.describe(file.path, fallbackTitle: fallbackTitle);
    } catch (error) {
      if (_engineMissing(error)) {
        return PdfDescription(title: fallbackTitle);
      }
      await _deleteQuiet(file);
      throw const PdfReadException();
    }
  }

  bool _engineMissing(Object error) {
    final text = error.toString();
    return text.contains('MethodNotImplemented') ||
        text.contains('MissingPluginException') ||
        text.contains('not been implemented') ||
        text.contains('not implemented');
  }

  Future<void> _deleteQuiet(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  Future<void> _keepCover(Book existing, EpubMetadata metadata) async {
    final coverBytes = metadata.coverBytes;
    final alreadyStored =
        existing.coverBytes != null && existing.coverBytes!.isNotEmpty;
    if (coverBytes == null || coverBytes.isEmpty || alreadyStored) return;

    final documents = await _documentsDirectory();
    final coverPath = await _writeCover(
      documents,
      existing.id,
      coverBytes,
      metadata.coverExtension,
    );
    await _repository.saveCover(
      id: existing.id,
      coverBytes: coverBytes,
      coverPath: coverPath,
    );
  }

  Future<int> _store(
    Uint8List bytes,
    EpubMetadata metadata,
    String contentHash,
  ) async {
    final documents = await _documentsDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final booksDir = Directory(p.join(documents.path, 'books'));
    await booksDir.create(recursive: true);

    final relativeEpub = p.join('books', '$stamp.epub');
    final epubFile = File(p.join(documents.path, relativeEpub));
    await epubFile.writeAsBytes(bytes, flush: true);

    String? coverPath;
    final coverBytes = metadata.coverBytes;
    if (coverBytes != null && coverBytes.isNotEmpty) {
      coverPath = await _writeCover(
        documents,
        stamp,
        coverBytes,
        metadata.coverExtension,
      );
    }

    return _repository.insert(
      title: metadata.title,
      author: metadata.author,
      bookUid: metadata.bookUid,
      filePath: relativeEpub,
      coverPath: coverPath,
      coverBytes: coverBytes,
      contentHash: contentHash,
    );
  }

  Future<String> _writeCover(
    Directory documents,
    Object name,
    Uint8List bytes,
    String? extension,
  ) async {
    final coversDir = Directory(p.join(documents.path, 'covers'));
    await coversDir.create(recursive: true);
    final relativeCover = p.join('covers', '$name.${extension ?? 'jpg'}');
    final coverFile = File(p.join(documents.path, relativeCover));
    await coverFile.writeAsBytes(bytes, flush: true);
    return relativeCover;
  }
}
