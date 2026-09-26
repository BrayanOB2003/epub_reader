import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  var _step = 0;
  var _saving = false;
  var _answers = const OnboardingAnswers();

  bool get _canContinue {
    return switch (_step) {
      1 => _answers.hasMotivations,
      2 => _answers.hasGoal,
      3 => _answers.hasReadingTime,
      _ => true,
    };
  }

  void _back() {
    if (_step == 0 || _saving) return;
    setState(() => _step -= 1);
  }

  Future<void> _forward() async {
    if (!_canContinue || _saving) return;
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete(_answers);
      if (!mounted) return;
      context.go('/library');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron guardar tus respuestas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _step == 0,
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
                          tooltip: 'Atrás',
                          onPressed: _saving ? null : _back,
                          icon: const Icon(Icons.arrow_back),
                        ),
                ),
                if (_step > 0) ...[
                  Text(
                    '$_step de 3',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(child: _stepBody(theme)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canContinue && !_saving ? _forward : null,
                    child: Text(
                      _step == 0
                          ? 'Empezar'
                          : (_step == 3
                                ? 'Quiero empezar a leer'
                                : 'Siguiente'),
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
    return switch (_step) {
      0 => _Welcome(theme: theme),
      1 => _Question(
        theme: theme,
        title: '¿Qué quieres conseguir con la lectura?',
        children: [
          for (final motivation in ReadingMotivation.values)
            _ChoiceTile(
              label: motivation.label,
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
        title: '¿Cuánto quieres leer?',
        children: [
          for (final minutes in readingGoalMinutes)
            _ChoiceTile(
              label: '$minutes minutos',
              selected: _answers.dailyGoalMinutes == minutes,
              onTap: () => setState(
                () => _answers = _answers.copyWith(dailyGoalMinutes: minutes),
              ),
            ),
        ],
      ),
      _ => _Question(
        theme: theme,
        title: '¿Cuándo te gustaría leer?',
        note: 'Más adelante podrás elegir los días.',
        children: [
          for (final routine in ReadingRoutine.values)
            _ChoiceTile(
              label: routine.label,
              selected: _answers.routine == routine,
              onTap: () =>
                  setState(() => _answers = _answers.withRoutine(routine)),
            ),
          if (_answers.routine != null) ...[
            const SizedBox(height: 16),
            Text('¿A qué hora?', style: theme.textTheme.titleMedium),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text('Crea el hábito de leer', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(
          'Un lugar para leer un poco cada día y sostener ese hábito.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Text(
          'Sin cuenta. Tus libros y tu progreso se guardan en este dispositivo.',
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
    this.note,
  });

  final ThemeData theme;
  final String title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(
            note!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...children,
      ],
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
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Material(
      color: selected ? color.primaryContainer : color.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? color.primary : color.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label, style: theme.textTheme.bodyLarge),
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
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? color.primaryContainer : color.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? color.primary : color.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
                if (selected) Icon(Icons.check, color: color.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
