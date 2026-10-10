import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How to let Shortcuts turn Do Not Disturb on when Liora opens.
class FocusGuidePage extends ConsumerStatefulWidget {
  const FocusGuidePage({super.key});

  @override
  ConsumerState<FocusGuidePage> createState() => _FocusGuidePageState();
}

class _FocusGuidePageState extends ConsumerState<FocusGuidePage> {
  var _busy = false;

  Future<void> _openShortcuts() async {
    if (_busy) return;
    setState(() => _busy = true);
    final opened = await ref.read(focusModeControllerProvider).openShortcuts();
    if (!mounted) return;
    setState(() => _busy = false);
    if (opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).focusGuideOpenFailed),
      ),
    );
  }

  Future<void> _done() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(readerProfileStoreProvider).setFocusMode(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).focusModeChangeFailed),
        ),
      );
      return;
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: l10n.back,
                onPressed: _busy ? null : () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ColoredBox(
                      color: colors.station,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 16, 20),
                        child: Text(
                          l10n.focusGuideTitle,
                          style: programTitle(colors.onStation, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.focusGuideBody, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 28),
                    _GuideBlock(
                      heading: l10n.focusGuideOpenHeading,
                      steps: l10n.focusGuideOpenSteps,
                    ),
                    const SizedBox(height: 24),
                    _GuideBlock(
                      heading: l10n.focusGuideCloseHeading,
                      steps: l10n.focusGuideCloseSteps,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScheduleAction(
                label: l10n.focusGuideOpenShortcuts,
                onPressed: _busy ? null : _openShortcuts,
              ),
              const SizedBox(height: 8),
              ScheduleAction(
                label: l10n.focusGuideDone,
                onPressed: _busy ? null : _done,
                onAir: true,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _busy ? null : () => context.pop(),
                  child: Text(l10n.focusGuideNotNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.heading, required this.steps});

  final String heading;
  final String steps;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          steps,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.ink,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
