import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The catalog log while the shelves are still unknown.
///
/// The title is real. The marks below it keep the same slots as a section,
/// a genre, and a cover listing, so the page does not jump when the books arrive.
class DiscoverSkeleton extends StatefulWidget {
  const DiscoverSkeleton({super.key});

  @override
  State<DiscoverSkeleton> createState() => _DiscoverSkeletonState();
}

class _DiscoverSkeletonState extends State<DiscoverSkeleton>
    with SingleTickerProviderStateMixin {
  static const _titleFactors = <double>[
    0.82,
    0.48,
    0.7,
    0.4,
    0.64,
    0.54,
    0.76,
    0.46,
  ];

  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = !MediaQuery.disableAnimationsOf(context);
    if (motion && !_sweep.isAnimating) {
      _sweep.repeat();
    } else if (!motion && (_sweep.isAnimating || _sweep.value != 0)) {
      _sweep
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final motion = !MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleHeader(title: l10n.discover),
        const ScheduleRule(),
        Expanded(
          child: Semantics(
            label: l10n.catalogLoading,
            excludeSemantics: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final marks = _marks(constraints.maxHeight);
                if (!motion) return marks;
                return RepaintBoundary(
                  child: _InkSweep(animation: _sweep, child: marks),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _marks(double maxHeight) {
    final marks = <Widget>[_constSection];
    if (!maxHeight.isFinite) {
      marks.add(const _GenreMark(width: 96));
      for (var i = 0; i < 4; i++) {
        marks.add(_ListingMark(titleFactor: _titleFactors[i]));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: marks,
      );
    }

    var used = _sectionExtent;
    var index = 0;
    var shelf = 0;
    while (shelf < 3 && index < _titleFactors.length) {
      final shelfCap = shelf == 0 ? 2 : 4;
      if (used + _genreExtent + _listingExtent > maxHeight) break;
      marks.add(_GenreMark(width: shelf == 0 ? 96 : 72));
      used += _genreExtent;
      var inShelf = 0;
      while (inShelf < shelfCap &&
          index < _titleFactors.length &&
          used + _listingExtent <= maxHeight) {
        marks.add(_ListingMark(titleFactor: _titleFactors[index]));
        used += _listingExtent;
        index++;
        inShelf++;
      }
      shelf++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: marks,
    );
  }
}

const _sectionExtent = 46.0;
const _genreExtent = 34.0;
const _listingExtent = 125.0;
const _constSection = _SectionMark();

Color _bone(ScheduleColors colors) {
  return Color.lerp(colors.rule, colors.ink, 0.14)!;
}

class _InkSweep extends StatelessWidget {
  const _InkSweep({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final base = _bone(colors);
    // Wet ink on the unprinted slots: toward ink, not paper.
    final wash = Color.lerp(base, colors.ink, 0.36)!;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [base, base, wash, base, base],
              stops: const [0.0, 0.10, 0.28, 0.46, 1.0],
              tileMode: TileMode.repeated,
              transform: _InkPress(animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

class _InkPress extends GradientTransform {
  const _InkPress(this.shift);

  final double shift;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(0, bounds.height * shift, 0);
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _bone(colors),
          borderRadius: scheduleRadius(context),
        ),
      ),
    );
  }
}

class _SectionMark extends StatelessWidget {
  const _SectionMark();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: _Mark(width: 148, height: 22),
    );
  }
}

class _GenreMark extends StatelessWidget {
  const _GenreMark({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: _Mark(width: width, height: 14),
    );
  }
}

class _ListingMark extends StatelessWidget {
  const _ListingMark({required this.titleFactor});

  final double titleFactor;

  @override
  Widget build(BuildContext context) {
    final radius = scheduleRadius(context);
    final colors = ScheduleColors.of(context);
    final bone = _bone(colors);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 108,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: bone, borderRadius: radius),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Mark(width: width * titleFactor, height: 18),
                        const SizedBox(height: 8),
                        _Mark(width: width * titleFactor * 0.62, height: 12),
                        const SizedBox(height: 6),
                        _Mark(width: width * 0.34, height: 12),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              const _Mark(width: 52, height: 12),
            ],
          ),
        ),
        const ScheduleRule(),
      ],
    );
  }
}
