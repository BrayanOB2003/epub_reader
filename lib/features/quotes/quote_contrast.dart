import 'dart:math' as math;
import 'dart:typed_data';

import 'package:epub_reader/features/quotes/quote_card_model.dart';

class QuoteBackgroundSample {
  const QuoteBackgroundSample(this.width, this.height, this.rgba);

  final int width;
  final int height;
  final Uint8List rgba;
}

class QuoteInkPick {
  const QuoteInkPick({
    required this.inkId,
    required this.veil,
    required this.contrast,
  });

  final String inkId;
  final double veil;
  final double contrast;
}

bool quoteInkIsLight(int rgb) => relativeLuminance(rgb) >= 0.5;

double relativeLuminance(int rgb) {
  final red = _linear((rgb >> 16) & 0xFF);
  final green = _linear((rgb >> 8) & 0xFF);
  final blue = _linear(rgb & 0xFF);
  return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

double contrastRatio(double first, double second) {
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Picks the palette color with the strongest worst-case contrast on the
/// quote band, then raises [veil] until the contrast clears 4.5:1.
QuoteInkPick suggestQuoteInk({
  required QuoteBackgroundSample sample,
  required double cardAspect,
  required double veil,
}) {
  var current = veil.clamp(0.0, quoteVeilMax);
  while (true) {
    final pick = bestQuoteInk(
      sample: sample,
      cardAspect: cardAspect,
      veil: current,
    );
    if (pick.contrast >= quoteContrastFloor ||
        current >= quoteVeilMax - 0.001) {
      return pick;
    }
    current = math.min(quoteVeilMax, current + quoteVeilStep);
  }
}

QuoteInkPick bestQuoteInk({
  required QuoteBackgroundSample sample,
  required double cardAspect,
  required double veil,
}) {
  final pixels = _bandPixels(sample, cardAspect);
  final alpha = veil.clamp(0.0, quoteVeilMax);
  final onBlack = _sortedLuminance(pixels, 0x000000, alpha);
  final onWhite = _sortedLuminance(pixels, 0xFFFFFF, alpha);
  var bestId = quoteInks.first.id;
  var bestScore = -1.0;
  for (final ink in quoteInks) {
    final band = quoteInkIsLight(ink.rgb) ? onBlack : onWhite;
    final score = math.min(
      contrastRatio(relativeLuminance(ink.rgb), _percentile(band, 0.20)),
      contrastRatio(relativeLuminance(ink.rgb), _percentile(band, 0.80)),
    );
    if (score > bestScore) {
      bestScore = score;
      bestId = ink.id;
    }
  }
  return QuoteInkPick(inkId: bestId, veil: alpha, contrast: bestScore);
}

List<int> _bandPixels(QuoteBackgroundSample sample, double cardAspect) {
  if (sample.width < 1 || sample.height < 1 || sample.rgba.length < 4) {
    return const [0x808080];
  }
  final crop = coverCrop(
    imageWidth: sample.width.toDouble(),
    imageHeight: sample.height.toDouble(),
    cardAspect: cardAspect,
  );
  final top = (crop.top + crop.height * 0.25).floor().clamp(
    0,
    sample.height - 1,
  );
  final bottom = (crop.top + crop.height * 0.75).ceil().clamp(
    top + 1,
    sample.height,
  );
  final left = crop.left.floor().clamp(0, sample.width - 1);
  final right = (crop.left + crop.width).ceil().clamp(left + 1, sample.width);
  final pixels = <int>[];
  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      final index = (y * sample.width + x) * 4;
      if (index + 2 >= sample.rgba.length) continue;
      final red = sample.rgba[index];
      final green = sample.rgba[index + 1];
      final blue = sample.rgba[index + 2];
      pixels.add((red << 16) | (green << 8) | blue);
    }
  }
  if (pixels.isEmpty) return const [0x808080];
  return pixels;
}

List<double> _sortedLuminance(List<int> pixels, int veilRgb, double alpha) {
  final values = <double>[
    for (final pixel in pixels)
      relativeLuminance(_blend(pixel, veilRgb, alpha)),
  ]..sort();
  return values;
}

int _blend(int rgb, int veil, double alpha) {
  final amount = alpha.clamp(0.0, 1.0);
  int channel(int source, int cover) {
    return (source * (1 - amount) + cover * amount).round().clamp(0, 255);
  }

  final red = channel((rgb >> 16) & 0xFF, (veil >> 16) & 0xFF);
  final green = channel((rgb >> 8) & 0xFF, (veil >> 8) & 0xFF);
  final blue = channel(rgb & 0xFF, veil & 0xFF);
  return (red << 16) | (green << 8) | blue;
}

double _percentile(List<double> sorted, double position) {
  if (sorted.isEmpty) return 0;
  final index = ((sorted.length - 1) * position).round();
  return sorted[index.clamp(0, sorted.length - 1)];
}

double _linear(int channel) {
  final value = channel / 255;
  if (value <= 0.04045) return value / 12.92;
  return math.pow((value + 0.055) / 1.055, 2.4).toDouble();
}
