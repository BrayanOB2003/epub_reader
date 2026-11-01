import 'dart:math' as math;

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:flutter/painting.dart';

class QuoteCardMeasure {
  const QuoteCardMeasure({required this.passageSize, required this.fits});

  final double passageSize;
  final bool fits;
}

String? quoteFontFamily(QuoteCardFont font) {
  return switch (font) {
    QuoteCardFont.serif => quoteSerifFace,
    QuoteCardFont.condensed => programFace,
    QuoteCardFont.plain => null,
  };
}

TextStyle quotePassageStyle({
  required QuoteCardFont font,
  required double fontSize,
  required Color color,
}) {
  return TextStyle(
    fontFamily: quoteFontFamily(font),
    fontFamilyFallback: const ['sans-serif'],
    fontWeight: font == QuoteCardFont.condensed
        ? FontWeight.w600
        : FontWeight.w400,
    fontSize: fontSize,
    height: switch (font) {
      QuoteCardFont.serif => 1.28,
      QuoteCardFont.condensed => 1.1,
      QuoteCardFont.plain => 1.35,
    },
    letterSpacing: font == QuoteCardFont.condensed ? fontSize * -0.02 : 0,
    color: color,
  );
}

TextStyle quoteAttributionStyle({
  required QuoteCardFont font,
  required double passageSize,
  required Color color,
}) {
  return quotePassageStyle(
    font: font,
    fontSize: passageSize * quoteAttributionScale,
    color: color,
  ).copyWith(height: 1.25, fontWeight: FontWeight.w400, letterSpacing: 0);
}

/// Shrinks from the preferred size down to a floor. [fits] is false when the
/// passage still overflows at that floor.
QuoteCardMeasure measureQuoteCard({
  required String passage,
  required String attribution,
  required double cardWidth,
  required double cardHeight,
  required QuoteCardFont font,
  required double textScale,
  required Color color,
}) {
  final width = cardWidth <= 0 ? 1.0 : cardWidth;
  final height = cardHeight <= 0 ? 1.0 : cardHeight;
  final contentWidth = width * quotePassageWidthFraction;
  final contentHeight = height * quoteContentHeightFraction;
  final preferred =
      width * 0.078 * textScale.clamp(quoteTextScaleMin, quoteTextScaleMax);
  final minimum = width * 0.034;
  final step = math.max(0.5, width * 0.004);
  var size = preferred < minimum ? minimum : preferred;
  while (true) {
    if (_fits(
      passage: passage,
      attribution: attribution,
      font: font,
      passageSize: size,
      color: color,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
    )) {
      return QuoteCardMeasure(passageSize: size, fits: true);
    }
    if (size <= minimum + 0.01) {
      return QuoteCardMeasure(passageSize: minimum, fits: false);
    }
    size = math.max(minimum, size - step);
  }
}

bool _fits({
  required String passage,
  required String attribution,
  required QuoteCardFont font,
  required double passageSize,
  required Color color,
  required double contentWidth,
  required double contentHeight,
}) {
  final passagePainter = TextPainter(
    text: TextSpan(
      text: passage,
      style: quotePassageStyle(font: font, fontSize: passageSize, color: color),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: contentWidth);
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
  final gap = attribution.trim().isEmpty
      ? 0.0
      : passageSize * quoteAttributionGapScale;
  final height =
      passagePainter.height +
      gap +
      (attribution.trim().isEmpty ? 0 : attributionPainter.height);
  final passageOverflows = passagePainter.computeLineMetrics().any(
    (line) => line.width > contentWidth + 0.5,
  );
  final attributionOverflows = attributionPainter.computeLineMetrics().any(
    (line) => line.width > contentWidth + 0.5,
  );
  return !passageOverflows &&
      !attributionOverflows &&
      height <= contentHeight + 0.5;
}
