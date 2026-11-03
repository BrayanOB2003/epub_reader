import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/premium/premium_controller.dart';
import 'package:epub_reader/features/premium/premium_gateway.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one payment. The profile only lists it; this page is the card that
/// carries the pitch, the three sections and the price.
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  String? _issue;
  bool _busy = false;

  Future<void> _buy() => _run(ref.read(premiumProvider.notifier).buy);

  Future<void> _restore() => _run(ref.read(premiumProvider.notifier).restore);

  Future<void> _run(Future<PremiumOutcome> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _issue = null;
    });
    final outcome = await action();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _issue = switch (outcome) {
        PremiumOutcome.unlocked || PremiumOutcome.cancelled => null,
        PremiumOutcome.pending => l10n.premiumPurchasePending,
        PremiumOutcome.nothingToRestore => l10n.premiumNothingToRestore,
        PremiumOutcome.failed => l10n.premiumPurchaseFailed,
        PremiumOutcome.unavailable => l10n.premiumPurchaseUnavailable,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final ink = typeOnStation(context);
    final premium = ref.watch(premiumProvider);
    final issue = _issue;
    // On short screens the headline gives up height so the three sections
    // and the stamp stay in view.
    final headlineSize = MediaQuery.sizeOf(context).height < 700 ? 54.0 : 68.0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          ThemeData.estimateBrightnessForColor(colors.station) ==
              Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.station,
        body: SafeArea(
          child: Column(
            children: [
              _CardTop(onBack: () => context.pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.premiumHeadline,
                          style: TextStyle(
                            fontFamily: programFace,
                            fontWeight: FontWeight.w600,
                            fontSize: headlineSize,
                            height: 0.92,
                            letterSpacing: -headlineSize * 0.02,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                    const _Stripe(),
                    _Feature(
                      title: l10n.monthReading,
                      body: l10n.premiumMonthBody,
                    ),
                    const _Hairline(),
                    _Feature(
                      title: l10n.readingByBook,
                      body: l10n.premiumBooksBody,
                    ),
                    const _Hairline(),
                    _Feature(
                      title: l10n.appearance,
                      body: l10n.premiumAppearanceBody,
                    ),
                  ],
                ),
              ),
              _StampBar(
                onePayment: premium.unlocked == true
                    ? l10n.premiumActive
                    : l10n.premiumOnePayment,
                note: premium.unlocked == true ? l10n.premiumActiveNote : null,
                label: premium.price == null
                    ? l10n.premiumUnlock
                    : l10n.premiumUnlockPrice(premium.price!),
                restoreLabel: l10n.premiumRestore,
                issue: issue,
                busy: _busy,
                onPressed: _buy,
                onRestore: _restore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTop extends StatelessWidget {
  const _CardTop({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ink = typeOnStation(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context).back,
            onPressed: onBack,
            color: ink,
            icon: Icon(ios ? CupertinoIcons.back : Icons.arrow_back),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ExcludeSemantics(
              child: Text(
                'LIORA',
                style: TextStyle(
                  fontFamily: programFace,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 2.4,
                  color: ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stripe extends StatelessWidget {
  const _Stripe();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 8,
        child: ColoredBox(color: typeOnStation(context)),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: ScheduleColors.of(context).onStationMuted),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = ScheduleColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: programFace,
              fontWeight: FontWeight.w600,
              fontSize: 30,
              height: 1,
              letterSpacing: -0.4,
              color: typeOnStation(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onStationMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StampBar extends StatelessWidget {
  const _StampBar({
    required this.onePayment,
    required this.note,
    required this.label,
    required this.restoreLabel,
    required this.issue,
    required this.busy,
    required this.onPressed,
    required this.onRestore,
  });

  final String onePayment;

  /// Shown instead of the stamp once premium is on.
  final String? note;
  final String label;
  final String restoreLabel;
  final String? issue;
  final bool busy;
  final VoidCallback onPressed;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final ink = typeOnStation(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ScheduleColors.of(context).station,
        border: Border(top: BorderSide(color: ink, width: 2)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottom > 0 ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (issue != null) ...[
              _StampIssue(message: issue!),
              const SizedBox(height: 12),
            ],
            Text(
              onePayment,
              style: TextStyle(
                fontFamily: programFace,
                fontWeight: FontWeight.w600,
                fontSize: 24,
                height: 1,
                color: ink,
              ),
            ),
            const SizedBox(height: 10),
            if (note != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  note!,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: ink, height: 1.4),
                ),
              )
            else ...[
              _Stamp(label: label, busy: busy, onPressed: onPressed),
              TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(
                  foregroundColor: ink,
                  minimumSize: const Size.fromHeight(48),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(restoreLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StampIssue extends StatelessWidget {
  const _StampIssue({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ink = typeOnStation(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ios ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
            size: 20,
            color: ink,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// The stamp: the paper tone on the station band. It lands once when the card opens, then holds still.
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final still = MediaQuery.disableAnimationsOf(context);
    final button = ios
        ? SizedBox(
            height: 56,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: colors.onStation,
              borderRadius: BorderRadius.zero,
              onPressed: onPressed,
              child: busy
                  ? CupertinoActivityIndicator(color: colors.station)
                  : Text(
                      label,
                      style: TextStyle(
                        color: colors.station,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.41,
                      ),
                    ),
            ),
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: colors.onStation,
              foregroundColor: colors.station,
              minimumSize: const Size.fromHeight(56),
              shape: const RoundedRectangleBorder(),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            child: busy
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.station,
                    ),
                  )
                : Text(label),
          );
    if (still) return button;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.12, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutExpo,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: button,
    );
  }
}
