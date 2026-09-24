import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';

const readerLightBackground = Color(0xFFF7F1E8);
const readerLightText = Color(0xFF2A2118);
const readerDarkBackground = Color(0xFF1A1714);
const readerDarkText = Color(0xFFE8E0D4);

EPUBPreferences readerPreferences({required bool dark, required bool scroll, required bool fixedLayout}) {
  if (fixedLayout) return const EPUBPreferences(scroll: false);
  return EPUBPreferences(
    scroll: scroll,
    publisherStyles: false,
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
