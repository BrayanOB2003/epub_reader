import 'dart:convert';
import 'dart:io';

import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/discover/data/catalog_cache.dart';
import 'package:epub_reader/features/discover/data/catalog_client.dart';
import 'package:epub_reader/features/discover/data/catalog_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogCache', () {
    late Directory directory;
    late CatalogCache cache;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('catalog_cache');
      cache = CatalogCache(directory: () async => directory);
    });

    tearDown(() async {
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    test('writes the envelope and reads it back', () async {
      final catalog = _catalog(
        title: 'Don Quijote',
        urlsExpireAt: DateTime.utc(2026, 9, 24, 6),
      );

      await cache.write(catalog);
      final saved = await cache.read();

      expect(saved, isNotNull);
      expect(saved!.savedAt, isNotNull);
      expect(saved.catalog.books.single.title, 'Don Quijote');
      expect(saved.catalog.urlsExpireAt, catalog.urlsExpireAt);
      expect(File('${directory.path}/catalog.json.tmp').existsSync(), isFalse);

      final raw =
          jsonDecode(
                await File('${directory.path}/catalog.json').readAsString(),
              )
              as Map;
      expect(raw['guardado_en'], isA<String>());
      expect(raw['catalogo'], isA<Map<String, dynamic>>());
    });

    test('replaces the previous copy', () async {
      await cache.write(
        _catalog(title: 'Viejo', urlsExpireAt: DateTime.utc(2026, 9, 24, 6)),
      );
      await cache.write(
        _catalog(title: 'Nuevo', urlsExpireAt: DateTime.utc(2026, 9, 24, 7)),
      );

      final saved = await cache.read();
      expect(saved!.catalog.books.single.title, 'Nuevo');
    });

    test('returns null when the file is missing or damaged', () async {
      expect(await cache.read(), isNull);

      await File('${directory.path}/catalog.json').writeAsString('{');
      expect(await cache.read(), isNull);
      expect(File('${directory.path}/catalog.json').existsSync(), isFalse);
    });
  });

  group('CatalogNotifier', () {
    late Directory directory;
    late _ScriptedCatalogClient client;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('catalog_notifier');
      client = _ScriptedCatalogClient();
    });

    tearDown(() async {
      client.close();
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    test('uses a valid copy and does not call the network', () async {
      final cache = CatalogCache(directory: () async => directory);
      await cache.write(
        _catalog(
          title: 'En caché',
          urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );

      final container = _container(directory, client);
      addTearDown(container.dispose);

      final catalog = await container.read(catalogProvider.future);
      await pumpEventQueue();

      expect(catalog.books.single.title, 'En caché');
      expect(client.calls, 0);
    });

    test(
      'keeps using the copy in a new session while the urls are valid',
      () async {
        final cache = CatalogCache(directory: () async => directory);
        await cache.write(
          _catalog(
            title: 'En caché',
            urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        );

        final first = _container(directory, client);
        expect(
          (await first.read(catalogProvider.future)).books.single.title,
          'En caché',
        );
        first.dispose();

        final second = _container(directory, client);
        addTearDown(second.dispose);
        expect(
          (await second.read(catalogProvider.future)).books.single.title,
          'En caché',
        );
        await pumpEventQueue();

        expect(client.calls, 0);
      },
    );

    test('shows an expired copy and then replaces it', () async {
      final cache = CatalogCache(directory: () async => directory);
      await cache.write(
        _catalog(
          title: 'Caducado',
          urlsExpireAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );
      client.next = _catalog(
        title: 'Nuevo',
        urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );

      final container = _container(directory, client);
      addTearDown(container.dispose);

      final shown = await container.read(catalogProvider.future);
      expect(shown.books.single.title, 'Caducado');

      await pumpEventQueue();

      expect(
        container.read(catalogProvider).value?.books.single.title,
        'Nuevo',
      );
      expect((await cache.read())!.catalog.books.single.title, 'Nuevo');
      expect(client.calls, 1);
    });

    test('keeps the expired copy when the refresh fails', () async {
      final cache = CatalogCache(directory: () async => directory);
      await cache.write(
        _catalog(
          title: 'Caducado',
          urlsExpireAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );
      client.fail = true;

      final container = _container(directory, client);
      addTearDown(container.dispose);

      final shown = await container.read(catalogProvider.future);
      await pumpEventQueue();

      expect(shown.books.single.title, 'Caducado');
      expect(
        container.read(catalogProvider).value?.books.single.title,
        'Caducado',
      );
      expect((await cache.read())!.catalog.books.single.title, 'Caducado');
    });

    test('fetches when there is no copy', () async {
      client.next = _catalog(
        title: 'Remoto',
        urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      final container = _container(directory, client);
      addTearDown(container.dispose);

      final catalog = await container.read(catalogProvider.future);

      expect(catalog.books.single.title, 'Remoto');
      expect(client.calls, 1);
      expect(
        (await CatalogCache(
          directory: () async => directory,
        ).read())!.catalog.books.single.title,
        'Remoto',
      );
    });

    test('reload ignores a valid copy', () async {
      final cache = CatalogCache(directory: () async => directory);
      await cache.write(
        _catalog(
          title: 'En caché',
          urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      client.next = _catalog(
        title: 'Actualizado',
        urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
      );

      final container = _container(directory, client);
      addTearDown(container.dispose);
      await container.read(catalogProvider.future);

      final fresh = await container.read(catalogProvider.notifier).reload();

      expect(fresh.books.single.title, 'Actualizado');
      expect(
        container.read(catalogProvider).value?.books.single.title,
        'Actualizado',
      );
      expect(client.calls, 1);
    });

    test('reload keeps the visible copy when the network fails', () async {
      final cache = CatalogCache(directory: () async => directory);
      await cache.write(
        _catalog(
          title: 'En caché',
          urlsExpireAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      final container = _container(directory, client);
      addTearDown(container.dispose);
      await container.read(catalogProvider.future);
      client.fail = true;

      await expectLater(
        container.read(catalogProvider.notifier).reload(),
        throwsA(isA<CatalogException>()),
      );

      expect(
        container.read(catalogProvider).value?.books.single.title,
        'En caché',
      );
    });
  });
}

Catalog _catalog({required String title, required DateTime urlsExpireAt}) {
  return Catalog(
    generatedAt: DateTime.utc(2026, 9, 24, 5),
    urlsExpireAt: urlsExpireAt,
    books: [
      CatalogBook(
        id: 'book.epub',
        title: title,
        downloadUrl: 'https://example.test/book.epub',
      ),
    ],
  );
}

ProviderContainer _container(
  Directory directory,
  _ScriptedCatalogClient client,
) {
  return ProviderContainer(
    overrides: [
      catalogCacheProvider.overrideWithValue(
        CatalogCache(directory: () async => directory),
      ),
      catalogClientProvider.overrideWith((ref) => client),
    ],
  );
}

class _ScriptedCatalogClient extends CatalogClient {
  _ScriptedCatalogClient() : super(apiKey: 'test');

  Catalog? next;
  var fail = false;
  var calls = 0;

  @override
  Future<Catalog> fetch() async {
    calls += 1;
    if (fail) throw const CatalogException('No se pudo cargar el catálogo.');
    return next!;
  }
}
