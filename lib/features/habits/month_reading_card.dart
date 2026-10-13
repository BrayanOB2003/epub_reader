import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MonthCardCopy {
  const MonthCardCopy({
    required this.month,
    required this.headline,
    required this.minutes,
    this.archetype,
  });

  final String month;
  final String headline;
  final String minutes;
  final String? archetype;
}

class MonthCardExport {
  MonthCardExport({Future<Directory> Function()? temporaryDirectory})
    : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectory;

  Future<File> writePng(Uint8List png) async {
    final dir = await _temporaryDirectory();
    final file = File(p.join(dir.path, 'liora-mes.png'));
    await file.writeAsBytes(png, flush: true);
    return file;
  }

  Future<void> share(String path, {Rect? origin}) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'image/png', name: 'liora-mes.png')],
        sharePositionOrigin: origin,
      ),
    );
  }
}

/// Square paper card: the month, the sentence, the minutes, and Liora.
Future<Uint8List> renderMonthCard(MonthCardCopy copy) async {
  const size = 1080.0;
  const inset = 72.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()..color = const Color(0xFFF4F7FB),
  );
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, 16),
    Paint()..color = const Color(0xFF0C4DA2),
  );
  final width = size - inset * 2;
  var y = 96.0;
  y = _drawText(
    canvas: canvas,
    text: copy.month,
    style: programTitle(const Color(0xFF0E1A2B), size: 72),
    x: inset,
    y: y,
    width: width,
    maxLines: 2,
  );
  y += 28;
  canvas.drawRect(
    Rect.fromLTWH(inset, y, width, 1),
    Paint()..color = const Color(0xFFD5DBE3),
  );
  y += 36;
  y = _drawText(
    canvas: canvas,
    text: copy.headline,
    style: const TextStyle(
      color: Color(0xFF0E1A2B),
      fontSize: 36,
      height: 1.35,
    ),
    x: inset,
    y: y,
    width: width,
    maxLines: 4,
  );
  y += 36;
  y = _drawText(
    canvas: canvas,
    text: copy.minutes,
    style: programTitle(const Color(0xFF0E1A2B), size: 56),
    x: inset,
    y: y,
    width: width,
  );
  final archetype = copy.archetype?.trim();
  if (archetype != null && archetype.isNotEmpty) {
    y += 20;
    _drawText(
      canvas: canvas,
      text: archetype,
      style: programTitle(const Color(0xFF0E1A2B), size: 44),
      x: inset,
      y: y,
      width: width,
      maxLines: 2,
    );
  }
  _drawText(
    canvas: canvas,
    text: 'Liora',
    style: programTitle(const Color(0xFF0C4DA2), size: 36),
    x: inset,
    y: size - 120,
    width: width,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('The month image could not be encoded.');
    }
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    image.dispose();
  }
}

double _drawText({
  required Canvas canvas,
  required String text,
  required TextStyle style,
  required double x,
  required double y,
  required double width,
  int maxLines = 1,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
    ellipsis: '…',
  )..layout(maxWidth: width);
  painter.paint(canvas, Offset(x, y));
  return y + painter.height;
}
