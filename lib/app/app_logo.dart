import 'package:flutter/material.dart';

/// The station mark. The asset already carries its own blue field.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
