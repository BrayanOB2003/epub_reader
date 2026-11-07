import 'dart:typed_data';

import 'package:epub_reader/core/reading/readium_reading_engine.dart';

/// The PDF could not be opened.
class PdfReadException implements Exception {
  const PdfReadException();
}

/// Title, author and first-page cover taken from a PDF.
class PdfDescription {
  const PdfDescription({
    required this.title,
    this.author,
    this.bookUid,
    this.coverBytes,
  });

  final String title;
  final String? author;
  final String? bookUid;
  final Uint8List? coverBytes;
}

/// Reads a PDF that is already on disk.
abstract class PdfDescriber {
  Future<PdfDescription> describe(
    String absolutePath, {
    required String fallbackTitle,
  });
}

class ReadiumPdfDescriber implements PdfDescriber {
  ReadiumPdfDescriber(this._engine);

  final ReadiumReadingEngine _engine;

  @override
  Future<PdfDescription> describe(
    String absolutePath, {
    required String fallbackTitle,
  }) async {
    final publication = await _engine.load(absolutePath);
    Uint8List? cover;
    try {
      cover = await _engine.cover(absolutePath);
    } catch (_) {
      cover = null;
    }
    final title = publication.metadata.title.trim();
    final authors = publication.metadata.authors
        .map((author) => author.name?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
    final uid = publication.metadata.identifier?.trim();
    final coverBytes = cover == null || cover.isEmpty ? null : cover;
    return PdfDescription(
      title: title.isEmpty ? fallbackTitle : title,
      author: authors.isEmpty ? null : authors,
      bookUid: uid == null || uid.isEmpty ? null : uid,
      coverBytes: coverBytes,
    );
  }
}
