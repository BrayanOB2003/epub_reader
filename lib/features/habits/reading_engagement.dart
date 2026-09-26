import 'package:flutter_readium/flutter_readium.dart';

const readingSegmentCap = Duration(minutes: 5);
const readingVisitMinimum = Duration(seconds: 30);
const readingProgressionEpsilon = 0.00001;

class ReadingSpot {
  const ReadingSpot({
    required this.resourceHref,
    this.progression,
    this.position,
  });

  final String resourceHref;
  final double? progression;
  final int? position;
}

ReadingSpot readingSpotFromLocator(Locator locator) {
  return ReadingSpot(
    resourceHref: locator.href.split('#').first,
    progression: locator.locations?.progression,
    position: locator.locations?.position,
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

  Duration _segmentStart = Duration.zero;
  var _segmentOpen = true;
  var _paused = false;
  var _hasAdvanced = false;
  var _awaitingAnchor = false;
  var finished = false;
  ReadingSpot? _anchor;

  bool get shouldPersist => engaged >= readingVisitMinimum;

  int get engagedSeconds => engaged.inSeconds;

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
      return;
    }
    if (sameReadingSpot(_anchor!, spot)) return;
    _creditCapped(_gap());
    _hasAdvanced = true;
    _anchor = spot;
    _segmentStart = _elapsed();
    _segmentOpen = true;
  }

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
