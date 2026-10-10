import 'package:epub_reader/features/quotes/quote_card_layout.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:epub_reader/features/quotes/quote_contrast.dart';
import 'package:flutter/material.dart';

class QuoteCardView extends StatelessWidget {
  const QuoteCardView({
    required this.background,
    required this.style,
    required this.passage,
    required this.attribution,
    required this.measure,
    required this.exportWidth,
    super.key,
  });

  final ImageProvider background;
  final QuoteCardStyle style;
  final String passage;
  final String attribution;
  final QuoteCardMeasure measure;
  final double exportWidth;

  @override
  Widget build(BuildContext context) {
    final color = Color(0xFF000000 | style.ink.rgb);
    final veil = quoteInkIsLight(style.ink.rgb)
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.noScaling),
      child: RepaintBoundary(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: background,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Color(0xFF0E1A2B)),
              ),
              ColoredBox(color: veil.withValues(alpha: style.veil)),
              LayoutBuilder(
                builder: (context, constraints) {
                  final scale = exportWidth <= 0
                      ? 1.0
                      : constraints.maxWidth / exportWidth;
                  final passageSize = measure.passageSize * scale;
                  final showAttribution = attribution.trim().isNotEmpty;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          constraints.maxWidth *
                          (1 - quotePassageWidthFraction) /
                          2,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          passage,
                          textAlign: TextAlign.center,
                          style: quotePassageStyle(
                            font: style.font,
                            fontSize: passageSize,
                            color: color,
                          ),
                        ),
                        if (showAttribution) ...[
                          SizedBox(
                            height: passageSize * quoteAttributionGapScale,
                          ),
                          Text(
                            attribution,
                            textAlign: TextAlign.center,
                            style: quoteAttributionStyle(
                              font: style.font,
                              passageSize: passageSize,
                              color: color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
