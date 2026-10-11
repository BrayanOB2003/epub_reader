import 'dart:io';

import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const bundledQuoteBackgroundIds = <String>[
  'pexels-agelos-grigoriou-169876553-11039566.jpg',
  'pexels-ahmet-kayra-174853248-30072885.jpg',
  'pexels-book-hut-440747141-19355509.jpg',
  'pexels-cafepolverini-13157038.jpg',
  'pexels-codioful-7130560.jpg',
  'pexels-codioful-7135006.jpg',
  'pexels-codioful-7135053.jpg',
  'pexels-fotios-photos-29622729.jpg',
  'pexels-hilalbulbul-18245110.jpg',
  'pexels-kseniya-lapteva-93670191-9175906.jpg',
  'pexels-kseniya-lapteva-93670191-9176118.jpg',
  'pexels-lumber-film-540218201-16557322.jpg',
  'pexels-mehmet-39418284.jpg',
  'pexels-olivers-36065721.jpg',
  'pexels-outandaboutwithliz-7553660.jpg',
  'pexels-pavel-danilyuk-6925017.jpg',
  'pexels-peter-dyllong-2158803154-36815103.jpg',
  'pexels-peter-steiner-1973-560957992-29218798.jpg',
  'pexels-ron-lach-10397033.jpg',
  'pexels-simon73-3408552.jpg',
  'pexels-yuuilina-9066470.jpg',
];

class StoredQuoteBackground {
  const StoredQuoteBackground({required this.id, required this.path});

  final String id;
  final String path;
}

class QuoteBackgroundException implements Exception {
  const QuoteBackgroundException.tooLarge() : tooLarge = true;
  const QuoteBackgroundException.notImage() : tooLarge = false;

  final bool tooLarge;
}

typedef PrepareQuoteBackground = (Uint8List?, String?) Function(
  Uint8List bytes,
);

/// Copies an imported photo down to a JPEG whose long side is at most 2000 px.
(Uint8List?, String?) prepareQuoteBackground(Uint8List bytes) {
  if (bytes.length > quoteBackgroundMaxBytes) return (null, 'large');
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null || decoded.width < 1 || decoded.height < 1) {
      return (null, 'invalid');
    }
    final oriented = img.bakeOrientation(decoded);
    final longSide = oriented.width > oriented.height
        ? oriented.width
        : oriented.height;
    final resized = longSide <= quoteBackgroundMaxSide
        ? oriented
        : img.copyResize(
            oriented,
            width: oriented.width >= oriented.height
                ? quoteBackgroundMaxSide
                : null,
            height: oriented.height > oriented.width
                ? quoteBackgroundMaxSide
                : null,
            interpolation: img.Interpolation.average,
          );
    return (Uint8List.fromList(img.encodeJpg(resized, quality: 85)), null);
  } catch (_) {
    return (null, 'invalid');
  }
}

class QuoteBackgroundStore {
  QuoteBackgroundStore({
    Future<Directory> Function()? documentsDirectory,
    PrepareQuoteBackground? prepare,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _prepare = prepare ?? prepareQuoteBackground,
       _isolate = prepare == null;

  final Future<Directory> Function() _documentsDirectory;
  final PrepareQuoteBackground _prepare;
  final bool _isolate;

  Future<List<StoredQuoteBackground>> list() async {
    final dir = await _directory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.jpg')
        .toList();
    files.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return [
      for (final file in files)
        StoredQuoteBackground(id: p.basename(file.path), path: file.path),
    ];
  }

  Future<StoredQuoteBackground> importBytes(Uint8List bytes) async {
    final prepared = _isolate
        ? await compute(prepareQuoteBackground, bytes)
        : _prepare(bytes);
    final jpeg = prepared.$1;
    if (jpeg == null) {
      if (prepared.$2 == 'large') {
        throw const QuoteBackgroundException.tooLarge();
      }
      throw const QuoteBackgroundException.notImage();
    }
    final dir = await _directory();
    final id = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, id));
    await file.writeAsBytes(jpeg, flush: true);
    return StoredQuoteBackground(id: id, path: file.path);
  }

  Future<void> delete(String id) async {
    final name = p.basename(id);
    if (name != id || !name.toLowerCase().endsWith('.jpg')) return;
    final file = File(p.join((await _directory()).path, name));
    if (file.existsSync()) await file.delete();
  }

  Future<Uint8List> load({required String id, required bool imported}) async {
    if (imported) {
      final name = p.basename(id);
      return File(p.join((await _directory()).path, name)).readAsBytes();
    }
    final data = await rootBundle.load('assets/backgrounds/$id');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Directory> _directory() async {
    final docs = await _documentsDirectory();
    final dir = Directory(p.join(docs.path, 'quote_backgrounds'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }
}
