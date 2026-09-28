import 'dart:async';

import 'package:epub_reader/app/app_locale.dart';
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
  String? _inFlightLanguage;

  @override
  Future<Catalog> build() async {
    final language = ref.watch(catalogLanguageProvider);
    final saved = await ref.watch(catalogCacheProvider).read(language);
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
    final language = ref.read(catalogLanguageProvider);
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted || ref.read(catalogLanguageProvider) != language) {
        return fresh;
      }
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
    final language = ref.read(catalogLanguageProvider);
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted || ref.read(catalogLanguageProvider) != language) return;
      state = AsyncData(fresh);
    } catch (error) {
      debugPrint('[catalog] no se pudo actualizar la copia $error');
    }
  }

  Future<Catalog> _fetchAndSave() {
    final language = ref.read(catalogLanguageProvider);
    final current = _inFlight;
    if (current != null && _inFlightLanguage == language) return current;

    final future = _fetchAndSaveOnce(language);
    _inFlight = future;
    _inFlightLanguage = language;
    future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
        _inFlightLanguage = null;
      }
    }).ignore();
    return future;
  }

  Future<Catalog> _fetchAndSaveOnce(String language) async {
    final client = await ref.read(catalogClientProvider.future);
    final catalog = await client.fetch(language);
    try {
      await ref.read(catalogCacheProvider).write(language, catalog);
    } catch (error) {
      debugPrint('[catalog] no se pudo guardar la copia $error');
    }
    return catalog;
  }
}
