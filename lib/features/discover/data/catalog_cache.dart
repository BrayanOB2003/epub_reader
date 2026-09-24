import 'dart:convert';
import 'dart:io';

import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CachedCatalog {
  const CachedCatalog({required this.savedAt, required this.catalog});

  final DateTime? savedAt;
  final Catalog catalog;
}

class CatalogCache {
  CatalogCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationCacheDirectory;

  static const fileName = 'catalog.json';

  final Future<Directory> Function() _directory;

  Future<CachedCatalog?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        await _deleteQuietly(file);
        return null;
      }
      final body = decoded['catalogo'];
      if (body is! Map) {
        await _deleteQuietly(file);
        return null;
      }
      return CachedCatalog(
        savedAt: _savedAt(decoded['guardado_en']),
        catalog: Catalog.fromJson(Map<String, dynamic>.from(body)),
      );
    } catch (_) {
      await _deleteQuietly(file);
      return null;
    }
  }

  Future<void> write(Catalog catalog) async {
    final directory = await _directory();
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, fileName));
    final temp = File(p.join(directory.path, '$fileName.tmp'));
    await temp.writeAsString(
      jsonEncode({
        'guardado_en': DateTime.now().toUtc().toIso8601String(),
        'catalogo': catalog.toJson(),
      }),
      flush: true,
    );
    try {
      await temp.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
    }
  }

  Future<File> _file() async {
    final directory = await _directory();
    return File(p.join(directory.path, fileName));
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (error) {
      debugPrint('[catalog] no se pudo borrar la copia dañada $error');
    }
  }
}

DateTime? _savedAt(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

final catalogCacheProvider = Provider<CatalogCache>((ref) => CatalogCache());
