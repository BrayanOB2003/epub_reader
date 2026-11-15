import 'package:epub_reader/features/habits/reading_estimate.dart';
import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:flutter_readium/flutter_readium.dart';

const readingSegmentCap = Duration(minutes: 5);

/// A page turned sooner than this was skimmed, not read. Its time still
/// counts, but it stays out of the pace.
const readingSkimPage = Duration(seconds: 5);
const readingVisitMinimum = Duration(seconds: 30);
const readingProgressionEpsilon = 0.00001;

class ReadingSpot {
  const ReadingSpot({
    required this.resourceHref,
    this.progression,
    this.position,
    this.resourceIndex,
    this.bookProgress,
  });

  final String resourceHref;
  final double? progression;
  final int? position;

  /// Place of the file in the reading order.
  final int? resourceIndex;

  /// Position in the book on the reading-order scale of [spineProgress].
  final double? bookProgress;
}

/// [hrefs] is the reading order. Without it the spot has no place in the
/// book, and its pages stay out of the pace.
ReadingSpot readingSpotFromLocator(
  Locator locator, {
  List<String> hrefs = const [],
}) {
  final progression = locator.locations?.progression;
  return ReadingSpot(
    resourceHref: locator.href.split('#').first,
    progression: progression,
    position: locator.locations?.position,
    resourceIndex: readingResourceIndex(hrefs, locator.href),
    bookProgress: spineProgress(
      hrefs: hrefs,
      href: locator.href,
      progression: progression,
    ),
  );
}

bool sameReadingSpot(ReadingSpot left, ReadingSpot right) {
  if (left.resourceHref != right.resourceHref) return false;
  if (left.position != null &&
      right.position != null &&
      left.position != right.position) {
    return false;
  }
  final leftProgression = left.progression;
  final rightProgression = right.progression;
  if (leftProgression == null || rightProgression == null) return true;
  return (leftProgression - rightProgression).abs() < readingProgressionEpsilon;
}

/// Conscious reading time for one visit.
///
/// A segment closes on a position change, on leaving the reader, or when the
/// app goes to the background. Each segment counts at most [readingSegmentCap].
/// Background time is excluded. The visit is worth keeping once [engaged]
/// reaches [readingVisitMinimum].
///
/// The pace ([paceTime] over [paceProgress]) takes only page turns that
/// move forward to the same file or the next one, after at least
/// [readingSkimPage] and under [readingSegmentCap] on the page. A jump the
/// app makes itself is announced with [expectJump].
class ReadingEngagement {
  ReadingEngagement({Duration Function()? elapsed, DateTime Function()? now})
    : _elapsed = elapsed ?? _systemElapsed(),
      _now = now ?? DateTime.now {
    startedAt = _now().toUtc();
    _segmentStart = _elapsed();
  }

  static Duration Function() _systemElapsed() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  final Duration Function() _elapsed;
  final DateTime Function() _now;

  late final DateTime startedAt;
  DateTime? endedAt;
  Duration engaged = Duration.zero;
  Duration paceTime = Duration.zero;
  double paceProgress = 0;

  /// In scroll mode a page is not a turn, so a short stop is not skimming.
  var scroll = false;

  var _jumpExpected = false;

  Duration _segmentStart = Duration.zero;
  var _segmentOpen = true;
  var _paused = false;
  var _hasAdvanced = false;
  var _awaitingAnchor = false;
  var finished = false;
  ReadingSpot? _anchor;

  bool get shouldPersist => engaged >= readingVisitMinimum;

  int get engagedSeconds => engaged.inSeconds;

  int get paceSeconds => paceTime.inSeconds;

  bool get advanced => _hasAdvanced;

  void onSpot(ReadingSpot spot) {
    if (finished || _paused) return;
    if (_anchor == null) {
      _anchor = spot;
      return;
    }
    if (_awaitingAnchor) {
      _anchor = spot;
      _segmentStart = _elapsed();
      _segmentOpen = true;
      _awaitingAnchor = false;
      _jumpExpected = false;
      return;
    }
    if (sameReadingSpot(_anchor!, spot)) return;
    final gap = _gap();
    _creditCapped(gap);
    if (!_jumpExpected) _creditPace(_anchor!, spot, gap);
    _jumpExpected = false;
    _hasAdvanced = true;
    _anchor = spot;
    _segmentStart = _elapsed();
    _segmentOpen = true;
  }

  /// The next move is the app's own (the index, a chapter button), so it
  /// does not count toward the pace. [jumpCancelled] undoes it when the move
  /// did not happen.
  void expectJump() {
    if (finished) return;
    _jumpExpected = true;
  }

  void jumpCancelled() => _jumpExpected = false;

  void preferencesChanged() {
    if (finished || _paused) return;
    _segmentStart = _elapsed();
    _segmentOpen = true;
    _awaitingAnchor = true;
  }

  void background() {
    if (finished || _paused) return;
    if (_segmentOpen && _hasAdvanced && !_awaitingAnchor) {
      final gap = _gap();
      if (gap < readingSegmentCap) _add(gap);
    }
    _segmentOpen = false;
    _paused = true;
  }

  void resume() {
    if (finished || !_paused) return;
    _paused = false;
    _segmentStart = _elapsed();
    _segmentOpen = true;
  }

  void close() {
    if (finished) return;
    if (!_paused && _segmentOpen) _creditCapped(_gap());
    finished = true;
    _segmentOpen = false;
  }

  void abandon() {
    if (finished) return;
    finished = true;
    _segmentOpen = false;
  }

  void _creditPace(ReadingSpot from, ReadingSpot to, Duration gap) {
    final fromIndex = from.resourceIndex;
    final toIndex = to.resourceIndex;
    final start = from.bookProgress;
    final end = to.bookProgress;
    if (fromIndex == null || toIndex == null || start == null || end == null) {
      return;
    }
    if (toIndex < fromIndex || toIndex > fromIndex + 1) return;
    final advance = end - start;
    if (advance <= 0) return;
    if (gap >= readingSegmentCap) return;
    if (!scroll && gap < readingSkimPage) return;
    paceTime += gap;
    paceProgress += advance;
  }

  Duration _gap() {
    final gap = _elapsed() - _segmentStart;
    if (gap.isNegative) return Duration.zero;
    return gap;
  }

  void _creditCapped(Duration gap) {
    if (gap <= Duration.zero) return;
    _add(gap < readingSegmentCap ? gap : readingSegmentCap);
  }

  void _add(Duration gap) {
    if (gap <= Duration.zero) return;
    engaged += gap;
    endedAt = _now().toUtc();
  }
}
