import 'dart:io';

import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const quoteBackgroundStorageBucket = 'epub-reader-6a972.firebasestorage.app';

const defaultQuoteBackgroundId =
    'pexels-agelos-grigoriou-169876553-11039566.jpg';

const defaultQuoteBackgroundAsset =
    'assets/backgrounds/$defaultQuoteBackgroundId';

const catalogQuoteBackgroundIds = <String>[
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

Uri quoteBackgroundUrl(String objectName) {
  return Uri.https(
    'firebasestorage.googleapis.com',
    '/v0/b/$quoteBackgroundStorageBucket/o/${Uri.encodeComponent(objectName)}',
    const {'alt': 'media'},
  );
}

String quoteBackgroundThumbName(String id) {
  final dot = id.lastIndexOf('.');
  final stem = dot <= 0 ? id : id.substring(0, dot);
  return '$stem.thumb.jpg';
}

typedef DownloadQuoteBackground = Future<Uint8List> Function(Uri uri);

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
    this._download,
    this._bundle,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _prepare = prepare ?? prepareQuoteBackground,
       _isolate = prepare == null;

  final Future<Directory> Function() _documentsDirectory;
  final PrepareQuoteBackground _prepare;
  final bool _isolate;
  final DownloadQuoteBackground? _download;
  final AssetBundle? _bundle;
  final Map<String, Future<File>> _inFlight = {};
  http.Client? _client;

  void close() {
    _client?.close();
    _client = null;
  }

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
    if (id == defaultQuoteBackgroundId) {
      return _asset(defaultQuoteBackgroundAsset);
    }
    return (await catalogFile(id)).readAsBytes();
  }

  /// Full catalog photo, or its thumbnail when [thumb] is set.
  ///
  /// The first call downloads the object. Later calls read the file already
  /// stored on disk.
  Future<File> catalogFile(String id, {bool thumb = false}) {
    if (!catalogQuoteBackgroundIds.contains(id)) {
      throw ArgumentError.value(id, 'id', 'fondo de catálogo desconocido');
    }
    final key = '${thumb ? 'thumb' : 'full'}:$id';
    final pending = _inFlight[key];
    if (pending != null) return pending;
    final future = _catalogFile(id, thumb: thumb);
    _inFlight[key] = future;
    future.whenComplete(() => _inFlight.remove(key));
    return future;
  }

  Future<File> _catalogFile(String id, {required bool thumb}) async {
    final file = await _catalogLocation(id, thumb: thumb);
    if (await file.exists() && await file.length() > 0) return file;
    final name = thumb ? quoteBackgroundThumbName(id) : id;
    final bytes = await (_download ?? _network)(quoteBackgroundUrl(name));
    if (bytes.isEmpty) {
      throw HttpException('fondo vacío', uri: quoteBackgroundUrl(name));
    }
    await _writeAtomic(file, bytes);
    return file;
  }

  Future<Uint8List> _network(Uri uri) async {
    final client = _client ??= http.Client();
    final response = await client.get(uri);
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw HttpException('fondo ${response.statusCode}', uri: uri);
    }
    return response.bodyBytes;
  }

  Future<Uint8List> _asset(String key) async {
    final data = await (_bundle ?? rootBundle).load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<File> _catalogLocation(String id, {required bool thumb}) async {
    final root = await _directory();
    final dir = Directory(
      p.join(root.path, 'catalog', thumb ? 'thumbs' : 'full'),
    );
    if (!dir.existsSync()) await dir.create(recursive: true);
    return File(p.join(dir.path, p.basename(id)));
  }

  Future<void> _writeAtomic(File file, Uint8List bytes) async {
    final temp = File('${file.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    try {
      await temp.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
    }
  }

  Future<Directory> _directory() async {
    final docs = await _documentsDirectory();
    final dir = Directory(p.join(docs.path, 'quote_backgrounds'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }
}
