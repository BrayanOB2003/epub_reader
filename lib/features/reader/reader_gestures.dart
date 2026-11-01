import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ReaderZone { previous, menu, next }

const shortTapDeadline = Duration(milliseconds: 200);

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

/// Watches touches on top of the reader without claiming any of them.
///
/// Every touch reaches Readium, so a tap on a highlight or a link stays with
/// it. Readium reports the other taps through `ReadiumReaderWidget.onTap`.
class ReaderGestureLayer extends StatelessWidget {
  const ReaderGestureLayer({
    required this.scroll,
    required this.textSelected,
    required this.onPageDrag,
    required this.onSelectionTap,
    super.key,
  });

  final bool scroll;
  final bool textSelected;

  /// A horizontal drag in page mode. Readium moves the page with the finger.
  final VoidCallback onPageDrag;

  /// A short tap while text is selected. Readium clears the selection and
  /// does not report the tap.
  final VoidCallback onSelectionTap;

  @override
  Widget build(BuildContext context) {
    return _PageDragObserver(
      enabled: !scroll && !textSelected,
      onDrag: onPageDrag,
      child: _SelectionTapObserver(
        enabled: textSelected,
        onShortTap: onSelectionTap,
      ),
    );
  }
}

/// Sees a horizontal drag without claiming it.
class _PageDragObserver extends StatefulWidget {
  const _PageDragObserver({
    required this.enabled,
    required this.onDrag,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onDrag;
  final Widget child;

  @override
  State<_PageDragObserver> createState() => _PageDragObserverState();
}

class _PageDragObserverState extends State<_PageDragObserver> {
  Offset? _origin;
  var _reported = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _origin = event.position;
        _reported = false;
      },
      onPointerMove: (event) {
        final origin = _origin;
        if (!widget.enabled || _reported || origin == null) return;
        final delta = event.position - origin;
        if (delta.dx.abs() <= kTouchSlop || delta.dx.abs() <= delta.dy.abs()) {
          return;
        }
        _reported = true;
        widget.onDrag();
      },
      onPointerUp: (_) => _clear(),
      onPointerCancel: (_) => _clear(),
      child: widget.child,
    );
  }

  void _clear() {
    _origin = null;
    _reported = false;
  }
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
