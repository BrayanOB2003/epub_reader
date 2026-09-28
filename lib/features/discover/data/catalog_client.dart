import 'dart:convert';

import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:epub_reader/features/discover/data/catalog_env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const catalogEndpoint =
    'https://us-central1-neat-nimbus-495221-t1.cloudfunctions.net/epub_catalogo';

class CatalogClient {
  CatalogClient({required this.apiKey, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  Future<Catalog> fetch(String language) async {
    final uri = Uri.parse(catalogEndpoint)
        .replace(queryParameters: {'idioma': language});
    debugPrint('[catalog] GET $uri');
    debugPrint(
      '[catalog] header X-Key: ${apiKey.isEmpty ? 'vacío' : 'presente, ${apiKey.length} caracteres'}',
    );
    try {
      final response = await _http.get(uri, headers: {'X-Key': apiKey});
      debugPrint('[catalog] status ${response.statusCode}');
      debugPrint('[catalog] body ${response.body}');
      if (response.statusCode != 200) {
        throw CatalogException(
          CatalogFailure.load,
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const CatalogException(CatalogFailure.format);
      }
      final catalog = Catalog.fromJson(Map<String, dynamic>.from(decoded));
      debugPrint(
        '[catalog] ${catalog.books.length} libros, urls expiran en ${catalog.urlsExpireAt}',
      );
      return catalog;
    } catch (error) {
      debugPrint('[catalog] error $error');
      rethrow;
    }
  }

  Future<Uint8List> download(String url) async {
    debugPrint('[catalog] descarga $url');
    if (url.isEmpty) {
      debugPrint('[catalog] descarga sin URL');
      throw const CatalogException(CatalogFailure.missingUrl);
    }
    try {
      final response = await _http.get(Uri.parse(url));
      debugPrint(
        '[catalog] descarga status ${response.statusCode}, ${response.bodyBytes.length} bytes',
      );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw CatalogException(
          CatalogFailure.download,
          statusCode: response.statusCode,
        );
      }
      return response.bodyBytes;
    } catch (error) {
      debugPrint('[catalog] error de descarga $error');
      rethrow;
    }
  }

  void close() => _http.close();
}

final catalogClientProvider = FutureProvider<CatalogClient>((ref) async {
  final apiKey = await loadCatalogApiKey();
  final client = CatalogClient(apiKey: apiKey);
  ref.onDispose(client.close);
  return client;
});
