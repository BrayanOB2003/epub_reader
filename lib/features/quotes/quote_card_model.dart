import 'dart:math' as math;

const quoteSerifFace = 'SourceSerif4';

const quoteTextScaleMin = 0.75;
const quoteTextScaleMax = 1.35;
const quoteVeilMax = 0.72;
const quoteVeilStep = 0.08;
const quoteContrastFloor = 4.5;

const quotePassageWidthFraction = 0.82;
const quoteContentHeightFraction = 0.78;
const quoteAttributionScale = 0.4;
const quoteAttributionGapScale = 0.45;

const quoteBackgroundMaxBytes = 25 * 1024 * 1024;
const quoteBackgroundMaxSide = 2000;

enum QuoteCardFormat { story, post, square, wallpaper }

enum QuoteCardFont { serif, condensed, plain }

class QuoteInk {
  const QuoteInk(this.id, this.rgb);

  final String id;
  final int rgb;
}

const quoteInks = <QuoteInk>[
  QuoteInk('paper', 0xF4F7FB),
  QuoteInk('white', 0xFFFFFF),
  QuoteInk('cream', 0xF3EDE2),
  QuoteInk('ink', 0x0E1A2B),
  QuoteInk('black', 0x141414),
  QuoteInk('station', 0x0C4DA2),
];

QuoteInk quoteInkById(String id) {
  for (final ink in quoteInks) {
    if (ink.id == id) return ink;
  }
  return quoteInks[3];
}

class QuoteCardStyle {
  const QuoteCardStyle({
    required this.format,
    required this.font,
    required this.textScale,
    required this.veil,
    required this.inkAutomatic,
    required this.inkId,
  });

  static const initial = QuoteCardStyle(
    format: QuoteCardFormat.story,
    font: QuoteCardFont.serif,
    textScale: 1,
    veil: 0,
    inkAutomatic: true,
    inkId: 'ink',
  );

  final QuoteCardFormat format;
  final QuoteCardFont font;
  final double textScale;
  final double veil;
  final bool inkAutomatic;
  final String inkId;

  QuoteInk get ink => quoteInkById(inkId);

  QuoteCardStyle copyWith({
    QuoteCardFormat? format,
    QuoteCardFont? font,
    double? textScale,
    double? veil,
    bool? inkAutomatic,
    String? inkId,
  }) {
    return QuoteCardStyle(
      format: format ?? this.format,
      font: font ?? this.font,
      textScale: (textScale ?? this.textScale).clamp(
        quoteTextScaleMin,
        quoteTextScaleMax,
      ),
      veil: (veil ?? this.veil).clamp(0.0, quoteVeilMax),
      inkAutomatic: inkAutomatic ?? this.inkAutomatic,
      inkId: inkId ?? this.inkId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'format': format.name,
      'font': font.name,
      'textScale': textScale,
      'veil': veil,
      'inkAutomatic': inkAutomatic,
      'inkId': inkId,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is QuoteCardStyle &&
        other.format == format &&
        other.font == font &&
        other.textScale == textScale &&
        other.veil == veil &&
        other.inkAutomatic == inkAutomatic &&
        other.inkId == inkId;
  }

  @override
  int get hashCode =>
      Object.hash(format, font, textScale, veil, inkAutomatic, inkId);

  static QuoteCardStyle fromJson(Map<String, Object?> json) {
    return QuoteCardStyle(
      format:
          _enumByName(QuoteCardFormat.values, json['format']) ??
          QuoteCardFormat.story,
      font:
          _enumByName(QuoteCardFont.values, json['font']) ??
          QuoteCardFont.serif,
      textScale: _clamped(
        json['textScale'],
        quoteTextScaleMin,
        quoteTextScaleMax,
        1,
      ),
      veil: _clamped(json['veil'], 0, quoteVeilMax, 0),
      inkAutomatic: json['inkAutomatic'] is bool
          ? json['inkAutomatic']! as bool
          : true,
      inkId: quoteInkById(json['inkId'] as String? ?? '').id,
    );
  }
}

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

double _clamped(Object? value, double min, double max, double fallback) {
  final number = value is num ? value.toDouble() : fallback;
  return number.clamp(min, max);
}

double quoteCardAspect(QuoteCardFormat format, double deviceAspect) {
  return switch (format) {
    QuoteCardFormat.story => 9 / 16,
    QuoteCardFormat.post => 4 / 5,
    QuoteCardFormat.square => 1,
    QuoteCardFormat.wallpaper => deviceAspect <= 0 ? 9 / 16 : deviceAspect,
  };
}

/// Export pixels. The long side is 1920, so a story card is 1080×1920.
(int width, int height) quoteExportPixels(double aspect) {
  const maxLong = 1920;
  if (aspect >= 1) {
    final height = math.max(1, (maxLong / aspect).round());
    return (maxLong, height);
  }
  final width = math.max(1, (maxLong * aspect).round());
  return (width, maxLong);
}

class QuoteCrop {
  const QuoteCrop(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

QuoteCrop coverCrop({
  required double imageWidth,
  required double imageHeight,
  required double cardAspect,
}) {
  if (imageWidth <= 0 || imageHeight <= 0 || cardAspect <= 0) {
    return QuoteCrop(0, 0, math.max(imageWidth, 0), math.max(imageHeight, 0));
  }
  final imageAspect = imageWidth / imageHeight;
  if (imageAspect > cardAspect) {
    final width = imageHeight * cardAspect;
    return QuoteCrop((imageWidth - width) / 2, 0, width, imageHeight);
  }
  final height = imageWidth / cardAspect;
  return QuoteCrop(0, (imageHeight - height) / 2, imageWidth, height);
}

String quoteAttribution({
  required String title,
  required String? author,
  required String untitled,
}) {
  final book = title.trim().isEmpty ? untitled : title.trim();
  final name = author?.trim() ?? '';
  if (name.isEmpty) return book;
  return '$book\n$name';
}

String quoteCardRoute(int quoteId) => '/quotes/$quoteId/card';
