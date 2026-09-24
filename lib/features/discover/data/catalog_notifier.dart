import 'dart:async';

import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/discover/data/catalog_cache.dart';
import 'package:epub_reader/features/discover/data/catalog_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogProvider = AsyncNotifierProvider<CatalogNotifier, Catalog>(
  CatalogNotifier.new,
);

class CatalogNotifier extends AsyncNotifier<Catalog> {
  Future<Catalog>? _inFlight;

  @override
  Future<Catalog> build() async {
    final saved = await ref.watch(catalogCacheProvider).read();
    if (saved == null) return _fetchAndSave();
    if (!saved.catalog.urlsExpired) return saved.catalog;

    unawaited(
      Future<void>(() async {
        if (!ref.mounted) return;
        await _revalidate();
      }),
    );
    return saved.catalog;
  }

  /// Replaces the on-screen catalog with a network response.
  /// A failed refresh keeps the copy already visible.
  Future<Catalog> reload() async {
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return fresh;
      state = AsyncData(fresh);
      return fresh;
    } catch (error, stackTrace) {
      if (ref.mounted && !state.hasValue) {
        state = AsyncError<Catalog>(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _revalidate() async {
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (error) {
      debugPrint('[catalog] no se pudo actualizar la copia $error');
    }
  }

  Future<Catalog> _fetchAndSave() {
    final current = _inFlight;
    if (current != null) return current;

    final future = _fetchAndSaveOnce();
    _inFlight = future;
    future
        .whenComplete(() {
          if (identical(_inFlight, future)) _inFlight = null;
        })
        .ignore();
    return future;
  }

  Future<Catalog> _fetchAndSaveOnce() async {
    final client = await ref.read(catalogClientProvider.future);
    final catalog = await client.fetch();
    try {
      await ref.read(catalogCacheProvider).write(catalog);
    } catch (error) {
      debugPrint('[catalog] no se pudo guardar la copia $error');
    }
    return catalog;
  }
}
