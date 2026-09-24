class Catalog {
  const Catalog({required this.generatedAt, required this.urlsExpireAt, required this.books});

  final DateTime? generatedAt;
  final DateTime? urlsExpireAt;
  final List<CatalogBook> books;

  bool get urlsExpired {
    final expiry = urlsExpireAt;
    if (expiry == null) return false;
    return !DateTime.now().toUtc().isBefore(expiry.toUtc());
  }

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final books = json['libros'];
    return Catalog(
      generatedAt: _date(json['generado_en']),
      urlsExpireAt: _date(json['urls_expiran_en']),
      books: books is List
          ? books.whereType<Map>().map((book) => CatalogBook.fromJson(Map<String, dynamic>.from(book))).toList()
          : const [],
    );
  }
}

class CatalogBook {
  const CatalogBook({
    required this.id,
    required this.title,
    required this.downloadUrl,
    this.authors,
    this.identifier,
    this.language,
    this.coverUrl,
    this.size,
  });

  final String id;
  final String title;
  final String? authors;
  final String? identifier;
  final String? language;
  final String? coverUrl;
  final String downloadUrl;
  final int? size;

  factory CatalogBook.fromJson(Map<String, dynamic> json) {
    final title = json['titulo'];
    final downloadUrl = json['descarga_url'];
    return CatalogBook(
      id: json['id']?.toString() ?? '',
      title: title is String && title.trim().isNotEmpty ? title.trim() : 'Sin título',
      authors: _text(json['autores']),
      identifier: _text(json['identificador']),
      language: _text(json['idioma']),
      coverUrl: _text(json['portada_url']),
      downloadUrl: downloadUrl is String ? downloadUrl : '',
      size: json['tamano'] is num ? (json['tamano'] as num).toInt() : null,
    );
  }
}

class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _text(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
