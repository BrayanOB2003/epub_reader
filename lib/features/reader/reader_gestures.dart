import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ReaderZone { previous, menu, next }

/// While text is selected, taps belong to Readium: it clears the selection
/// and ignores the tap, so the page never turns under an active selection.
/// Side taps are claimed in both modes. In scroll mode they change chapter.
bool readerClaimsTap({required bool textSelected}) => !textSelected;

const shortTapDeadline = Duration(milliseconds: 200);

/// A page turn is a flick: the finger moves and lifts in one motion.
const pageTurnSwipeDeadline = Duration(milliseconds: 400);
const pageTurnMinDistance = 56.0;

/// `true` turns forward. A slow release, a short move, or a vertical drag does not.
bool? pageTurnSwipe({
  required double dx,
  required double dy,
  required Duration elapsed,
  required bool rtl,
}) {
  if (elapsed > pageTurnSwipeDeadline) return null;
  if (dx.abs() < pageTurnMinDistance || dx.abs() <= dy.abs()) return null;
  final forward = rtl ? dx > 0 : dx < 0;
  return forward;
}

/// Index of the spine resource a side tap opens while scrolling.
///
/// Scroll mode lays out one reading-order resource at a time. Fragments are
/// ignored so a locator inside `chapter.xhtml#p3` still matches that chapter.
int? adjacentChapterIndex({
  required List<String> hrefs,
  required String currentHref,
  required bool forward,
}) {
  if (hrefs.isEmpty) return null;
  final resource = _resourceHref(currentHref);
  final index = hrefs.indexWhere((href) => _resourceHref(href) == resource);
  if (index < 0) return null;
  final next = index + (forward ? 1 : -1);
  if (next < 0 || next >= hrefs.length) return null;
  return next;
}

String _resourceHref(String href) => href.split('#').first;

ReaderZone readerZoneAt({
  required double x,
  required double width,
  required bool rtl,
}) {
  if (width <= 0) return ReaderZone.menu;
  final fraction = (x / width).clamp(0.0, 1.0);
  if (fraction < 0.2) return rtl ? ReaderZone.next : ReaderZone.previous;
  if (fraction >= 0.8) return rtl ? ReaderZone.previous : ReaderZone.next;
  return ReaderZone.menu;
}

class ReaderGestureLayer extends StatelessWidget {
  const ReaderGestureLayer({
    required this.rtl,
    required this.scroll,
    required this.textSelected,
    required this.onZone,
    required this.onSwipe,
    required this.onSelectionTap,
    super.key,
  });

  final bool rtl;
  final bool scroll;
  final bool textSelected;
  final ValueChanged<ReaderZone> onZone;
  final ValueChanged<bool> onSwipe;
  final VoidCallback onSelectionTap;

  @override
  Widget build(BuildContext context) {
    final gestures = <Type, GestureRecognizerFactory>{
      _ShortTapRecognizer:
          GestureRecognizerFactoryWithHandlers<_ShortTapRecognizer>(
            () => _ShortTapRecognizer(),
            (recognizer) {
              recognizer.shouldClaim = (position) => _claims(context, position);
              recognizer.onShortTap = (position) =>
                  _dispatch(context, position);
            },
          ),
    };
    if (!scroll && !textSelected) {
      gestures[_PageTurnSwipeRecognizer] =
          GestureRecognizerFactoryWithHandlers<_PageTurnSwipeRecognizer>(
            () => _PageTurnSwipeRecognizer(),
            (recognizer) {
              recognizer.rtl = rtl;
              recognizer.onTurn = onSwipe;
            },
          );
    }
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: gestures,
      child: _SelectionTapObserver(
        enabled: textSelected,
        onShortTap: onSelectionTap,
      ),
    );
  }

  bool _claims(BuildContext context, Offset global) =>
      readerClaimsTap(textSelected: textSelected);

  void _dispatch(BuildContext context, Offset global) {
    onZone(_zone(context, global));
  }

  ReaderZone _zone(BuildContext context, Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return ReaderZone.menu;
    final local = box.globalToLocal(global);
    return readerZoneAt(x: local.dx, width: box.size.width, rtl: rtl);
  }
}

class _ShortTapRecognizer extends PrimaryPointerGestureRecognizer {
  _ShortTapRecognizer() : super(deadline: shortTapDeadline);

  bool Function(Offset globalPosition)? shouldClaim;
  void Function(Offset globalPosition)? onShortTap;

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      final claim = shouldClaim?.call(event.position) ?? true;
      if (!claim) {
        resolve(GestureDisposition.rejected);
      }
      return;
    }
    if (event is! PointerUpEvent) return;
    final position = event.position;
    final claim = shouldClaim?.call(position) ?? true;
    if (!claim) {
      resolve(GestureDisposition.rejected);
      return;
    }
    resolve(GestureDisposition.accepted);
    if (onShortTap != null) {
      invokeCallback<void>('onShortTap', () => onShortTap!(position));
    }
  }

  @override
  void didExceedDeadlineWithEvent(PointerDownEvent event) {
    resolve(GestureDisposition.rejected);
  }

  @override
  String get debugDescription => 'short tap';
}

/// Claims a horizontal flick in book mode so Readium does not turn the page,
/// then turns only if the finger lifts before [pageTurnSwipeDeadline].
class _PageTurnSwipeRecognizer extends PrimaryPointerGestureRecognizer {
  _PageTurnSwipeRecognizer()
    : super(
        deadline: shortTapDeadline,
        preAcceptSlopTolerance: null,
        postAcceptSlopTolerance: null,
      );

  bool rtl = false;
  ValueChanged<bool>? onTurn;
  Offset? _origin;
  Duration? _started;
  var _claimed = false;

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _origin = event.position;
      _started = event.timeStamp;
      _claimed = false;
      return;
    }
    final origin = _origin;
    final started = _started;
    if (origin == null || started == null) return;
    final dx = event.position.dx - origin.dx;
    final dy = event.position.dy - origin.dy;
    if (event is PointerMoveEvent && !_claimed) {
      if (dy.abs() > kTouchSlop && dy.abs() > dx.abs()) {
        resolve(GestureDisposition.rejected);
        return;
      }
      if (dx.abs() > kTouchSlop && dx.abs() > dy.abs()) {
        _claimed = true;
        resolve(GestureDisposition.accepted);
      }
      return;
    }
    if (event is! PointerUpEvent || !_claimed) {
      if (event is PointerUpEvent) resolve(GestureDisposition.rejected);
      return;
    }
    final forward = pageTurnSwipe(
      dx: dx,
      dy: dy,
      elapsed: event.timeStamp - started,
      rtl: rtl,
    );
    if (forward != null && onTurn != null) {
      invokeCallback<void>('onTurn', () => onTurn!(forward));
    }
  }

  @override
  void didExceedDeadlineWithEvent(PointerDownEvent event) {
    if (!_claimed) resolve(GestureDisposition.rejected);
  }

  @override
  String get debugDescription => 'page turn swipe';
}

/// Sees the tap that was given to Readium and clears the selection flag only
/// when it was a short tap. A drag that adjusts the selection keeps the flag.
class _SelectionTapObserver extends StatefulWidget {
  const _SelectionTapObserver({
    required this.enabled,
    required this.onShortTap,
  });

  final bool enabled;
  final VoidCallback onShortTap;

  @override
  State<_SelectionTapObserver> createState() => _SelectionTapObserverState();
}

class _SelectionTapObserverState extends State<_SelectionTapObserver> {
  Offset? _origin;
  Duration? _started;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (!widget.enabled) return;
        _origin = event.position;
        _started = event.timeStamp;
      },
      onPointerUp: (event) {
        final origin = _origin;
        final started = _started;
        _origin = null;
        _started = null;
        if (!widget.enabled || origin == null || started == null) return;
        final distance = (event.position - origin).distance;
        final elapsed = event.timeStamp - started;
        if (distance <= kTouchSlop && elapsed <= shortTapDeadline) {
          widget.onShortTap();
        }
      },
      child: const SizedBox.expand(),
    );
  }
}
