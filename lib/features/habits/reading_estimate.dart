import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:flutter_readium/flutter_readium.dart';

/// Below this, the pace is a guess and nothing is shown.
const readingEstimateMinSeconds = 120;

/// Below this, a little time stretches into an implausible pace.
const readingEstimateMinProgress = 0.02;

/// Closing the book offers to stay when the chapter has this long left, or less.
const readingChapterFinishMinutes = 5;

class ChapterSpan {
  const ChapterSpan(this.start, this.end);

  /// Start and end as fractions of the book, on the spine scale.
  final double start;
  final double end;
}

class ReadingEstimate {
  const ReadingEstimate({this.bookMinutes, this.chapterMinutes});

  final int? bookMinutes;
  final int? chapterMinutes;

  bool get chapterAlmostDone =>
      chapterMinutes != null && chapterMinutes! <= readingChapterFinishMinutes;

  static const none = ReadingEstimate();
}

/// Seconds already read, counting the open session once.
int engagedSecondsNow({
  required int storedSeconds,
  required int? openSessionSeconds,
  required int liveSeconds,
}) {
  if (openSessionSeconds == null) return storedSeconds + liveSeconds;
  final earlier = storedSeconds - openSessionSeconds;
  return (earlier < 0 ? 0 : earlier) + liveSeconds;
}

/// Nearest minute under 10, nearest 5 minutes from there up.
/// Under half a minute is too small to show.
int? readingMinutes(int seconds) {
  if (seconds < 30) return null;
  final minutes = seconds / 60;
  if (minutes < 10) {
    final rounded = minutes.round();
    return rounded == 0 ? null : rounded;
  }
  final rounded = (minutes / 5).round() * 5;
  return rounded == 0 ? null : rounded;
}

/// [progress], [chapterStart] and [chapterEnd] share one scale from 0 to 1.
/// A missing chapter bound leaves [ReadingEstimate.chapterMinutes] empty.
ReadingEstimate estimateReading({
  required int engagedSeconds,
  required double progress,
  double? chapterStart,
  double? chapterEnd,
}) {
  if (engagedSeconds < readingEstimateMinSeconds) return ReadingEstimate.none;
  if (progress < readingEstimateMinProgress || progress >= 1) {
    return ReadingEstimate.none;
  }
  final pace = engagedSeconds / progress;
  final bookMinutes = readingMinutes((pace * (1 - progress)).round());
  int? chapterMinutes;
  final start = chapterStart;
  final end = chapterEnd;
  if (start != null &&
      end != null &&
      end > start &&
      progress >= start &&
      progress < end) {
    chapterMinutes = readingMinutes((pace * (end - progress)).round());
  }
  return ReadingEstimate(
    bookMinutes: bookMinutes,
    chapterMinutes: chapterMinutes,
  );
}

/// Position in the book from the file's place in the reading order.
///
/// The same scale as [chapterSpan], so the two can be passed together.
double? spineProgress({
  required List<String> hrefs,
  required String href,
  double? progression,
}) {
  final index = readingResourceIndex(hrefs, href);
  if (index == null || hrefs.isEmpty) return null;
  final within = (progression ?? 0).clamp(0.0, 1.0);
  return (index + within) / hrefs.length;
}

/// The current chapter as a fraction of the book, or null when the cut is
/// not one file or a run of files between two index entries.
///
/// An empty [contents] treats each reading-order file as a chapter.
/// A fixed-layout book has no reliable cut; the caller skips it.
ChapterSpan? chapterSpan({
  required List<String> hrefs,
  required List<Link> contents,
  required String href,
}) {
  if (hrefs.isEmpty) return null;
  final index = readingResourceIndex(hrefs, href);
  if (index == null) return null;

  final leaves = contents.isEmpty
      ? [for (final item in hrefs) Link(href: item)]
      : _leaves(contents);
  final countAt = <int, int>{};
  for (final leaf in leaves) {
    final leafIndex = readingResourceIndex(hrefs, leaf.href);
    if (leafIndex == null) continue;
    countAt[leafIndex] = (countAt[leafIndex] ?? 0) + 1;
  }
  if ((countAt[index] ?? 0) > 1) return null;

  final starts = [
    for (final entry in countAt.entries)
      if (entry.value == 1) entry.key,
  ]..sort();
  int? start;
  for (final boundary in starts) {
    if (boundary <= index) start = boundary;
  }
  if (start == null) return null;
  final later = starts.where((boundary) => boundary > index);
  final end = later.isEmpty ? hrefs.length : later.first;
  for (final entry in countAt.entries) {
    if (entry.value > 1 && entry.key > start && entry.key < end) return null;
  }
  return ChapterSpan(start / hrefs.length, end / hrefs.length);
}

List<Link> _leaves(List<Link> links) {
  final leaves = <Link>[];
  void walk(List<Link> links) {
    for (final link in links) {
      if (link.children.isEmpty) {
        leaves.add(link);
      } else {
        walk(link.children);
      }
    }
  }

  walk(links);
  return leaves;
}
