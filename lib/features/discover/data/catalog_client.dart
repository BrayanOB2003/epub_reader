import 'dart:convert';

import 'package:epub_reader/features/discover/data/catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const catalogEndpoint =
    'https://us-central1-neat-nimbus-495221-t1.cloudfunctions.net/epub_catalogo';

class CatalogClient {
  CatalogClient({required this.apiKey, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  Future<Catalog> fetch() async {
    debugPrint('[catalog] GET $catalogEndpoint');
    debugPrint(
      '[catalog] header X-Key: ${apiKey.isEmpty ? 'vacío' : 'presente, ${apiKey.length} caracteres'}',
    );
    try {
      final response = await _http.get(
        Uri.parse(catalogEndpoint),
        headers: {'X-Key': apiKey},
      );
      debugPrint('[catalog] status ${response.statusCode}');
      debugPrint('[catalog] body ${response.body}');
      if (response.statusCode != 200) {
        throw CatalogException(
          'No se pudo cargar el catálogo (${response.statusCode}).',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const CatalogException(
          'El catálogo no tiene el formato esperado.',
        );
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
      throw const CatalogException('Este libro no tiene enlace de descarga.');
    }
    try {
      final response = await _http.get(Uri.parse(url));
      debugPrint(
        '[catalog] descarga status ${response.statusCode}, ${response.bodyBytes.length} bytes',
      );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw CatalogException(
          'No se pudo descargar el libro (${response.statusCode}).',
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
