import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_day_row.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HabitEditPage extends ConsumerWidget {
  const HabitEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(readerProfileProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadFailed(message: l10n.profileLoadFailed),
          data: (saved) {
            if (saved == null) {
              return _LoadFailed(message: l10n.profileLoadFailed);
            }
            return _HabitEditor(saved: saved);
          },
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScheduleDetailTitle(
          title: AppLocalizations.of(context).readingHabit,
          onBack: () => context.pop(),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ScheduleIssue(message: message),
        ),
      ],
    );
  }
}

class _HabitEditor extends ConsumerStatefulWidget {
  const _HabitEditor({required this.saved});

  final ReaderProfile saved;

  @override
  ConsumerState<_HabitEditor> createState() => _HabitEditorState();
}

class _HabitEditorState extends ConsumerState<_HabitEditor> {
  late OnboardingAnswers _answers;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.saved;
    _answers = OnboardingAnswers.fromStored(
      motivations: saved.motivations,
      dailyGoalMinutes: saved.dailyGoalMinutes,
      routine: saved.routine,
      routineHour: saved.routineHour,
      routineDays: saved.routineDays,
    );
  }

  bool get _canSave => _answers.isComplete && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete(_answers);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.habitSaved)));
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.answersSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = _answers.routine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScheduleDetailTitle(
          title: l10n.readingHabit,
          onBack: _saving ? null : () => context.pop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _SectionLabel(title: l10n.goalQuestion),
              for (final minutes in readingGoalMinutes)
                _Choice(
                  label: l10n.minutes(minutes),
                  selected: _answers.dailyGoalMinutes == minutes,
                  onTap: () => setState(
                    () => _answers = _answers.copyWith(
                      dailyGoalMinutes: minutes,
                    ),
                  ),
                ),
              _SectionLabel(title: l10n.whenQuestion),
              for (final routine in ReadingRoutine.values)
                _Choice(
                  label: routine.label(l10n),
                  selected: period == routine,
                  onTap: () => setState(
                    () => _answers = _answers.withRoutine(routine),
                  ),
                ),
              if (period != null) ...[
                _SectionLabel(title: l10n.whichDays),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ReadingDayRow(
                    selected: _answers.weekdays,
                    onToggle: (day) {
                      final next = {..._answers.weekdays};
                      if (!next.add(day)) next.remove(day);
                      setState(
                        () => _answers = _answers.copyWith(weekdays: next),
                      );
                    },
                  ),
                ),
                _SectionLabel(title: l10n.whatTime),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ReadingHourWrap(
                    hours: period.hours,
                    selected: _answers.routineHour,
                    onSelected: (hour) => setState(
                      () => _answers = _answers.copyWith(routineHour: hour),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const ScheduleRule(),
        ScheduleAction(
          label: l10n.save,
          onPressed: _canSave ? _save : null,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ScheduleColors.of(context).muted,
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
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
    final ink = selected ? typeOnStation(context) : colors.ink;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Material(
        color: selected ? colors.station : colors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: scheduleRadius(context),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ink,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check, color: typeOnStation(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
