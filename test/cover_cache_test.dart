import 'dart:io';
import 'dart:typed_data';

import 'package:epub_reader/features/discover/data/cover_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cover_cache');
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  test('a cover is downloaded once and reused when the url changes', () async {
    var downloads = 0;
    final cache = CoverCache(
      directory: () async => directory,
      download: (uri) async {
        downloads += 1;
        return Uint8List.fromList([1, 2, 3, downloads]);
      },
    );

    final first = await cache.load(
      id: 'book-1',
      url: 'https://cdn.example/cover?token=a',
    );
    final second = await cache.load(
      id: 'book-1',
      url: 'https://cdn.example/cover?token=b',
    );
    final again = CoverCache(
      directory: () async => directory,
      download: (uri) async {
        downloads += 1;
        return Uint8List.fromList([9]);
      },
    );
    final fromDisk = await again.load(
      id: 'book-1',
      url: 'https://cdn.example/cover?token=c',
    );

    expect(downloads, 1);
    expect(second, first);
    expect(fromDisk, first);
  });

  test('two loads of the same cover share one download', () async {
    var downloads = 0;
    final cache = CoverCache(
      directory: () async => directory,
      download: (uri) async {
        downloads += 1;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return Uint8List.fromList([4, 5, 6]);
      },
    );

    final results = await Future.wait([
      cache.load(id: 'book-2', url: 'https://cdn.example/a.jpg'),
      cache.load(id: 'book-2', url: 'https://cdn.example/a.jpg'),
    ]);

    expect(downloads, 1);
    expect(results[0], results[1]);
  });

  test('a failed download leaves no file', () async {
    final cache = CoverCache(
      directory: () async => directory,
      download: (uri) async => throw StateError('red'),
    );

    final bytes = await cache.load(
      id: 'book-3',
      url: 'https://cdn.example/missing.jpg',
    );

    expect(bytes, isNull);
    final covers = Directory('${directory.path}/covers');
    if (covers.existsSync()) {
      expect(covers.listSync(), isEmpty);
    }
  });
}
