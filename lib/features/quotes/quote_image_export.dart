import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QuoteImageExport {
  QuoteImageExport({Future<Directory> Function()? temporaryDirectory})
    : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectory;

  Future<File> writePng(Uint8List png) async {
    final dir = await _temporaryDirectory();
    final file = File(p.join(dir.path, 'liora-cita.png'));
    await file.writeAsBytes(png, flush: true);
    return file;
  }

  Future<void> share(String path, {Rect? origin}) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'image/png', name: 'liora-cita.png')],
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> saveToPhotos(String path) async {
    final allowed = await Gal.hasAccess() || await Gal.requestAccess();
    if (!allowed) throw StateError('photo access denied');
    await Gal.putImage(path);
  }
}
