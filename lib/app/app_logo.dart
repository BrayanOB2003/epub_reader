import 'dart:ui' as ui;

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// The station mark. The asset is a blue field; the field is repainted in the
/// appearance's station color, and the pale square follows that same color.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final image = Image(
      image: ThemedLogoImage(
        station: colors.station,
        mark: colors.onStation,
        accent: logoFieldAccent(colors.station, colors.onStation),
      ),
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _logoField(size, colors.station);
      },
      errorBuilder: (context, error, stackTrace) {
        return _logoField(size, colors.station);
      },
    );
    return ClipRRect(borderRadius: BorderRadius.circular(5), child: image);
  }
}

Widget _logoField(double size, Color color) {
  return SizedBox(
    width: size,
    height: size,
    child: ColoredBox(color: color),
  );
}

/// The light square on the mark, held between the station field and the paper
/// that sits on it.
Color logoFieldAccent(Color station, Color onStation) {
  return Color.lerp(station, onStation, 0.45)!;
}

/// One channel triple, 0–255.
typedef LogoRgb = ({int r, int g, int b});

/// Blue field baked into `assets/logo/mark.png`.
const logoSourceField = (r: 1, g: 75, b: 167);

/// Paper squares baked into the mark.
const logoSourceMark = (r: 250, g: 250, b: 250);

/// Pale square baked into the mark.
const logoSourceAccent = (r: 126, g: 167, b: 228);

LogoRgb logoRgb(Color color) {
  final argb = color.toARGB32();
  return (r: (argb >> 16) & 0xff, g: (argb >> 8) & 0xff, b: argb & 0xff);
}

/// Maps one pixel of the baked mark onto the appearance colors.
LogoRgb recolorLogoRgb(
  int r,
  int g,
  int b, {
  required LogoRgb station,
  required LogoRgb mark,
  required LogoRgb accent,
}) {
  final fieldWeight = _logoWeight(r, g, b, logoSourceField);
  final markWeight = _logoWeight(r, g, b, logoSourceMark);
  final accentWeight = _logoWeight(r, g, b, logoSourceAccent);
  final total = fieldWeight + markWeight + accentWeight;
  return (
    r: _logoMix(
      station.r,
      mark.r,
      accent.r,
      fieldWeight,
      markWeight,
      accentWeight,
      total,
    ),
    g: _logoMix(
      station.g,
      mark.g,
      accent.g,
      fieldWeight,
      markWeight,
      accentWeight,
      total,
    ),
    b: _logoMix(
      station.b,
      mark.b,
      accent.b,
      fieldWeight,
      markWeight,
      accentWeight,
      total,
    ),
  );
}

const _logoAsset = 'assets/logo/mark.png';

img.Image? _logoSource;
final _themedLogoPng = <int, Uint8List>{};

/// Recolors [bytes] of the station mark. The decoded source is kept so the
/// next appearance does not decode the file again.
Uint8List recolorLogoPng(
  Uint8List bytes, {
  required LogoRgb station,
  required LogoRgb mark,
  required LogoRgb accent,
}) {
  final key = Object.hash(
    station.r,
    station.g,
    station.b,
    mark.r,
    mark.g,
    mark.b,
    accent.r,
    accent.g,
    accent.b,
  );
  final cached = _themedLogoPng[key];
  if (cached != null) return cached;
  final image = _decodedLogo(bytes).clone();
  for (final pixel in image) {
    final next = recolorLogoRgb(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
      station: station,
      mark: mark,
      accent: accent,
    );
    pixel
      ..r = next.r
      ..g = next.g
      ..b = next.b;
  }
  final png = img.encodePng(image);
  _themedLogoPng[key] = png;
  return png;
}

img.Image _decodedLogo(Uint8List bytes) {
  final cached = _logoSource;
  if (cached != null) return cached;
  final decoded = img.decodePng(bytes);
  if (decoded == null) {
    throw StateError('The station mark could not be read.');
  }
  _logoSource = decoded;
  return decoded;
}

double _logoWeight(int r, int g, int b, LogoRgb source) {
  final dr = r - source.r;
  final dg = g - source.g;
  final db = b - source.b;
  return 1 / (dr * dr + dg * dg + db * db + 16);
}

int _logoMix(
  int station,
  int mark,
  int accent,
  double fieldWeight,
  double markWeight,
  double accentWeight,
  double total,
) {
  return ((station * fieldWeight + mark * markWeight + accent * accentWeight) /
          total)
      .round()
      .clamp(0, 255);
}

/// The mark, keyed by the three colors it is painted with.
class ThemedLogoImage extends ImageProvider<ThemedLogoImage> {
  const ThemedLogoImage({
    required this.station,
    required this.mark,
    required this.accent,
  });

  final Color station;
  final Color mark;
  final Color accent;

  @override
  Future<ThemedLogoImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ThemedLogoImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ThemedLogoImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: 1,
      debugLabel: 'themed logo',
    );
  }

  Future<ui.Codec> _load(
    ThemedLogoImage key,
    ImageDecoderCallback decode,
  ) async {
    final data = await rootBundle.load(_logoAsset);
    final png = recolorLogoPng(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      station: logoRgb(key.station),
      mark: logoRgb(key.mark),
      accent: logoRgb(key.accent),
    );
    return decode(await ui.ImmutableBuffer.fromUint8List(png));
  }

  @override
  bool operator ==(Object other) {
    return other is ThemedLogoImage &&
        other.station == station &&
        other.mark == mark &&
        other.accent == accent;
  }

  @override
  int get hashCode => Object.hash(station, mark, accent);
}
