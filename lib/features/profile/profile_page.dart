import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(readerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar el perfil.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (saved) {
          final goal = saved == null
              ? 'Sin definir'
              : '${saved.dailyGoalMinutes} minutos';
          return ListView(
            children: [
              const Divider(height: 1),
              ListTile(
                title: const Text('Meta de lectura diaria'),
                trailing: Text(goal),
                onTap: saved == null
                    ? null
                    : () => _pickGoal(context, ref, saved.dailyGoalMinutes),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Resetear onboarding'),
                onTap: () => _resetOnboarding(context, ref),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickGoal(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Meta de lectura diaria'),
        children: [
          for (final minutes in readingGoalMinutes)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, minutes),
              child: Text('$minutes minutos'),
            ),
        ],
      ),
    );
    if (selected == null || selected == current || !context.mounted) return;
    try {
      await ref.read(readerProfileStoreProvider).updateDailyGoal(selected);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la meta de lectura.')),
      );
    }
  }

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear onboarding'),
        content: const Text('Volverás a ver la bienvenida y las preguntas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(onboardingControllerProvider.notifier).reset();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo resetear el onboarding.')),
      );
    }
  }
}
