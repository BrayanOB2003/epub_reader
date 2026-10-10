import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingRoute extends ConsumerWidget {
  const OnboardingRoute({super.key, required this.editing});

  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!editing) return const OnboardingPage();
    final profile = ref.watch(readerProfileProvider);
    return profile.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context).profileLoadFailed('$error'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (saved) {
        if (saved == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return OnboardingPage(
          key: const ValueKey('edit-onboarding'),
          editing: true,
          initial: OnboardingAnswers.fromStored(
            motivations: saved.motivations,
            dailyGoalMinutes: saved.dailyGoalMinutes,
            routine: saved.routine,
            routineHour: saved.routineHour,
            routineDays: saved.routineDays,
          ),
        );
      },
    );
  }
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.initial, this.editing = false});

  final OnboardingAnswers? initial;
  final bool editing;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late int _step;
  late OnboardingAnswers _answers;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _step = widget.editing ? 1 : 0;
    _answers = widget.initial ?? const OnboardingAnswers();
  }

  bool get _canContinue {
    return switch (_step) {
      1 => _answers.hasMotivations,
      2 => _answers.hasGoal,
      3 => _answers.hasReadingTime,
      _ => true,
    };
  }

  bool get _atStart => widget.editing ? _step <= 1 : _step == 0;

  void _back() {
    if (_saving) return;
    if (_atStart) {
      if (widget.editing) context.pop();
      return;
    }
    setState(() => _step -= 1);
  }

  Future<void> _forward() async {
    final l10n = AppLocalizations.of(context);
    if (!_canContinue || _saving) return;
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete(_answers);
      if (!mounted) return;
      final pending = ref.read(pendingNotificationLocationProvider);
      ref.read(pendingNotificationLocationProvider.notifier).clear();
      context.go(
        notificationLanding(editing: widget.editing, pendingLocation: pending),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.answersSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: _atStart,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: _step == 0
                      ? null
                      : IconButton(
                          tooltip: l10n.back,
                          onPressed: _saving ? null : _back,
                          icon: const Icon(Icons.arrow_back),
                        ),
                ),
                Expanded(child: _stepBody(theme)),
                const SizedBox(height: 16),
                if (_step > 0) ...[
                  Text(
                    l10n.stepOf(_step, 3),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canContinue && !_saving ? _forward : null,
                    child: Text(
                      _step == 0
                          ? l10n.start
                          : (_step == 3 ? l10n.startReading : l10n.next),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return switch (_step) {
      0 => _Welcome(theme: theme),
      1 => _Question(
        theme: theme,
        title: l10n.motivationQuestion,
        children: [
          for (final motivation in ReadingMotivation.values)
            _ChoiceTile(
              label: motivation.label(l10n),
              selected: _answers.motivations.contains(motivation),
              onTap: () {
                final next = {..._answers.motivations};
                if (!next.add(motivation)) next.remove(motivation);
                setState(() => _answers = _answers.copyWith(motivations: next));
              },
            ),
        ],
      ),
      2 => _Question(
        theme: theme,
        title: l10n.goalQuestion,
        children: [
          for (final minutes in readingGoalMinutes)
            _ChoiceTile(
              label: l10n.minutes(minutes),
              selected: _answers.dailyGoalMinutes == minutes,
              onTap: () => setState(
                () => _answers = _answers.copyWith(dailyGoalMinutes: minutes),
              ),
            ),
        ],
      ),
      _ => _Question(
        theme: theme,
        title: l10n.whenQuestion,
        children: [
          for (final routine in ReadingRoutine.values)
            _ChoiceTile(
              label: routine.label(l10n),
              selected: _answers.routine == routine,
              onTap: () =>
                  setState(() => _answers = _answers.withRoutine(routine)),
            ),
          if (_answers.routine != null) ...[
            const SizedBox(height: 16),
            Text(l10n.whichDays, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final day in ReadingWeekday.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _DayLetter(
                        letter: day.letter(l10n),
                        label: day.label(l10n),
                        selected: _answers.weekdays.contains(day),
                        onTap: () {
                          final next = {..._answers.weekdays};
                          if (!next.add(day)) next.remove(day);
                          setState(
                            () => _answers = _answers.copyWith(weekdays: next),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.whatTime, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hour in _answers.routine!.hours)
                  _HourChip(
                    label: readingHourLabel(hour),
                    selected: _answers.routineHour == hour,
                    onTap: () => setState(
                      () => _answers = _answers.copyWith(routineHour: hour),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    };
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        ColoredBox(
          color: colors.station,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 16, 20),
            child: Text(
              l10n.welcomeTitle,
              style: programTitle(colors.onStation, size: 44),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.welcomeBody, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text(
          l10n.welcomeAccount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.theme,
    required this.title,
    required this.children,
  });

  final ThemeData theme;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class _DayLetter extends StatelessWidget {
  const _DayLetter({
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final ink = selected ? colors.onStation : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: selected ? colors.station : colors.paper,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: selected ? colors.station : colors.rule),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  letter,
                  style: theme.textTheme.titleMedium?.copyWith(color: ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final ink = selected ? colors.onStation : colors.ink;
    return Material(
      color: selected ? colors.station : colors.paper,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: selected ? colors.station : colors.rule),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final ink = selected ? colors.onStation : colors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.station : colors.paper,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: selected ? colors.station : colors.rule),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(color: ink),
                    ),
                  ),
                  if (selected) Icon(Icons.check, color: colors.onStation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
