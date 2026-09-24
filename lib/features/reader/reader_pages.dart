import 'package:flutter_readium/flutter_readium.dart';

/// Publication page reported by Readium. [Locations.position] counts pages
/// across the book. `currentPage` is only the page inside the current chapter.
int? bookPage(Locator locator) {
  final position = locator.locations?.position;
  if (position == null || position < 1) return null;
  return position;
}

/// Estimates how many pages the book has from the current position and the
/// publication progression. Readium reports progression as
/// `(page - 1) / total`.
int? estimatedTotalPages({required int? position, required double? totalProgression}) {
  if (position == null || position <= 1 || totalProgression == null || totalProgression <= 0) return null;
  final estimate = ((position - 1) / totalProgression).round();
  if (estimate < position) return null;
  return estimate;
}

/// Maps a book page onto a spine item and a progression inside that item.
({int index, double progression}) spineTarget({required int page, required int total, required int chapterCount}) {
  final fraction = total <= 1 ? 0.0 : ((page - 1) / (total - 1)).clamp(0.0, 1.0);
  if (chapterCount <= 1) return (index: 0, progression: fraction);
  if (fraction >= 1) return (index: chapterCount - 1, progression: 1);
  final scaled = fraction * chapterCount;
  final index = scaled.floor().clamp(0, chapterCount - 1);
  return (index: index, progression: (scaled - index).clamp(0.0, 1.0));
}
