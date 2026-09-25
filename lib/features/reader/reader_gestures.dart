import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ReaderZone { previous, menu, next }

/// While text is selected, taps belong to Readium: it clears the selection
/// and ignores the tap, so the page never turns under an active selection.
bool readerClaimsTap({required bool textSelected, required bool scroll, required ReaderZone zone}) {
  if (textSelected) return false;
  if (!scroll) return true;
  return zone == ReaderZone.menu;
}

const shortTapDeadline = Duration(milliseconds: 200);

ReaderZone readerZoneAt({required double x, required double width, required bool rtl}) {
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
    required this.onSelectionTap,
    super.key,
  });

  final bool rtl;
  final bool scroll;
  final bool textSelected;
  final ValueChanged<ReaderZone> onZone;
  final VoidCallback onSelectionTap;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: <Type, GestureRecognizerFactory>{
        _ShortTapRecognizer: GestureRecognizerFactoryWithHandlers<_ShortTapRecognizer>(
          () => _ShortTapRecognizer(),
          (recognizer) {
            recognizer.shouldClaim = (position) => _claims(context, position);
            recognizer.onShortTap = (position) => _dispatch(context, position);
            recognizer.onReleasedToReader = () {
              if (textSelected) onSelectionTap();
            };
          },
        ),
      },
      child: const SizedBox.expand(),
    );
  }

  bool _claims(BuildContext context, Offset global) =>
      readerClaimsTap(textSelected: textSelected, scroll: scroll, zone: _zone(context, global));

  void _dispatch(BuildContext context, Offset global) {
    final zone = _zone(context, global);
    if (scroll && zone != ReaderZone.menu) return;
    onZone(scroll ? ReaderZone.menu : zone);
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
  VoidCallback? onReleasedToReader;

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is! PointerUpEvent) return;
    final position = event.position;
    final claim = shouldClaim?.call(position) ?? true;
    if (!claim) {
      resolve(GestureDisposition.rejected);
      onReleasedToReader?.call();
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
