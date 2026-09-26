import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';

const readerLightBackground = Color(0xFFF7F1E8);
const readerLightText = Color(0xFF2A2118);
const readerDarkBackground = Color(0xFF1A1714);
const readerDarkText = Color(0xFFE8E0D4);

/// Room under the always-visible progress bar so the first line does not sit on it.
const readerProgressClearance = 12.0;

const readerFontSizeDefault = 1.0;
const readerFontSizeMin = 0.8;
const readerFontSizeMax = 2.0;
const readerFontSizeStep = 0.1;

double stepReaderFontSize(double current, {required bool larger}) {
  final delta = larger ? readerFontSizeStep : -readerFontSizeStep;
  final next = ((current + delta) * 10).round() / 10;
  return next.clamp(readerFontSizeMin, readerFontSizeMax);
}

EPUBPreferences readerPreferences({
  required bool dark,
  required bool scroll,
  required bool fixedLayout,
  double fontSize = readerFontSizeDefault,
}) {
  if (fixedLayout) return const EPUBPreferences(scroll: false);
  return EPUBPreferences(
    scroll: scroll,
    publisherStyles: false,
    fontSize: fontSize,
    backgroundColor: dark ? readerDarkBackground : readerLightBackground,
    textColor: dark ? readerDarkText : readerLightText,
  );
}

bool publicationIsFixed(Publication publication) {
  final layout = publication.metadata.layout?.toLowerCase();
  if (layout == 'fixed') return true;
  if (publication.metadata.presentation.layout == EpubLayout.fixed) return true;
  final order = publication.readingOrder;
  if (order.isEmpty) return false;
  return order.every((link) => link.properties.layout == EpubLayout.fixed);
}
