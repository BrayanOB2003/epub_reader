import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverCache {
  CoverCache({
    Future<Directory> Function()? directory,
    Future<Uint8List> Function(Uri uri)? download,
  }) : this._(directory ?? getApplicationCacheDirectory, download);

  CoverCache._(this._directory, this._download);

  final Future<Directory> Function() _directory;
  final Future<Uint8List> Function(Uri uri)? _download;
  final Map<String, Uint8List> _memory = {};
  final Map<String, Future<Uint8List?>> _inFlight = {};
  http.Client? _client;

  Future<Uint8List?> load({required String id, String? url}) {
    final key = id.isNotEmpty ? id : url;
    if (key == null || key.isEmpty) return Future.value();
    final remembered = _memory[key];
    if (remembered != null) return Future.value(remembered);
    final pending = _inFlight[key];
    if (pending != null) return pending;
    final future = _load(key, url);
    _inFlight[key] = future;
    return future;
  }

  void close() {
    _client?.close();
    _client = null;
  }

  Future<Uint8List?> _load(String key, String? url) async {
    try {
      final file = await _file(key);
      if (await file.exists()) {
        final stored = await file.readAsBytes();
        if (stored.isNotEmpty) {
          _memory[key] = stored;
          return stored;
        }
      }
      final source = url;
      if (source == null || source.isEmpty) return null;
      final uri = Uri.tryParse(source);
      if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
        return null;
      }
      final bytes = await (_download ?? _network).call(uri);
      if (bytes.isEmpty) return null;
      await _write(file, bytes);
      _memory[key] = bytes;
      return bytes;
    } catch (_) {
      return null;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<Uint8List> _network(Uri uri) async {
    final client = _client ??= http.Client();
    final response = await client.get(uri);
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw HttpException('portada ${response.statusCode}', uri: uri);
    }
    return response.bodyBytes;
  }

  Future<File> _file(String key) async {
    final directory = Directory(p.join((await _directory()).path, 'covers'));
    await directory.create(recursive: true);
    final name = sha256.convert(utf8.encode(key)).toString();
    return File(p.join(directory.path, name));
  }

  Future<void> _write(File file, Uint8List bytes) async {
    final temp = File('${file.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    try {
      await temp.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
    }
  }
}

final coverCacheProvider = Provider<CoverCache>((ref) {
  final cache = CoverCache();
  ref.onDispose(cache.close);
  return cache;
});
