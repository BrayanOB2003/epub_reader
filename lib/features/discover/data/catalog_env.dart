import 'package:flutter/services.dart';

import 'package:epub_reader/features/discover/data/catalog.dart';

const catalogEnvAsset = '.env/.env';

Future<String> loadCatalogApiKey({AssetBundle? bundle}) async {
  final raw = await (bundle ?? rootBundle).loadString(catalogEnvAsset);
  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final separator = trimmed.contains(':') ? ':' : '=';
    final parts = trimmed.split(separator);
    if (parts.length < 2 || parts.first.trim() != 'X_EPUB_KEY') continue;
    final value = parts.sublist(1).join(separator).trim();
    if (value.isEmpty) break;
    return value;
  }
  throw const CatalogException(CatalogFailure.missingKey);
}
