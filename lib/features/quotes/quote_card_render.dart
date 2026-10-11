import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:epub_reader/features/quotes/quote_card_layout.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:epub_reader/features/quotes/quote_contrast.dart';
import 'package:flutter/painting.dart';

Future<QuoteBackgroundSample> sampleQuoteBackground(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) {
        return QuoteBackgroundSample(
          1,
          1,
          Uint8List.fromList(const [128, 128, 128, 255]),
        );
      }
      return QuoteBackgroundSample(
        image.width,
        image.height,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

Future<Uint8List> renderQuoteCard({
  required Uint8List background,
  required QuoteCardStyle style,
  required double aspect,
  required String passage,
  required String attribution,
}) async {
  final pixels = quoteExportPixels(aspect);
  final width = pixels.$1;
  final height = pixels.$2;
  final ink = style.ink;
  final color = Color(0xFF000000 | ink.rgb);
  final measure = measureQuoteCard(
    passage: passage,
    attribution: attribution,
    cardWidth: width.toDouble(),
    cardHeight: height.toDouble(),
    font: style.font,
    textScale: style.textScale,
    color: color,
  );
  final codec = await ui.instantiateImageCodec(background, targetWidth: width);
  ui.Image? photo;
  try {
    photo = (await codec.getNextFrame()).image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.clipRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    _paintCover(canvas, photo, width.toDouble(), height.toDouble());
    final veil = quoteInkIsLight(ink.rgb)
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = veil.withValues(alpha: style.veil),
    );
    _paintCopy(
      canvas: canvas,
      passage: passage,
      attribution: attribution,
      font: style.font,
      color: color,
      passageSize: measure.passageSize,
      cardWidth: width.toDouble(),
      cardHeight: height.toDouble(),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('The quote image could not be encoded.');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  } finally {
    photo?.dispose();
    codec.dispose();
  }
}

void _paintCover(Canvas canvas, ui.Image image, double width, double height) {
  final crop = coverCrop(
    imageWidth: image.width.toDouble(),
    imageHeight: image.height.toDouble(),
    cardAspect: width / height,
  );
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
    Rect.fromLTWH(0, 0, width, height),
    Paint(),
  );
}

void _paintCopy({
  required Canvas canvas,
  required String passage,
  required String attribution,
  required QuoteCardFont font,
  required Color color,
  required double passageSize,
  required double cardWidth,
  required double cardHeight,
}) {
  final contentWidth = cardWidth * quotePassageWidthFraction;
  final left = (cardWidth - contentWidth) / 2;
  final passagePainter = TextPainter(
    text: TextSpan(
      text: passage,
      style: quotePassageStyle(font: font, fontSize: passageSize, color: color),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: contentWidth);
  final showAttribution = attribution.trim().isNotEmpty;
  final attributionPainter = TextPainter(
    text: TextSpan(
      text: attribution,
      style: quoteAttributionStyle(
        font: font,
        passageSize: passageSize,
        color: color,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: contentWidth);
  final gap = showAttribution ? passageSize * quoteAttributionGapScale : 0.0;
  final block =
      passagePainter.height +
      gap +
      (showAttribution ? attributionPainter.height : 0);
  var top = (cardHeight - block) / 2;
  passagePainter.paint(canvas, Offset(left, top));
  if (!showAttribution) return;
  top += passagePainter.height + gap;
  attributionPainter.paint(canvas, Offset(left, top));
}
