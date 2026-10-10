import 'dart:convert';
import 'dart:io';

import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class QuoteCardStyleStore {
  QuoteCardStyleStore({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<QuoteCardStyle> read() async {
    final file = await _file();
    if (!file.existsSync()) return QuoteCardStyle.initial;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return QuoteCardStyle.initial;
      return QuoteCardStyle.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return QuoteCardStyle.initial;
    }
  }

  Future<void> write(QuoteCardStyle style) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(style.toJson()), flush: true);
  }

  Future<File> _file() async {
    final docs = await _documentsDirectory();
    return File(p.join(docs.path, 'quote_card_style.json'));
  }
}
