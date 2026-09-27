import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                title: const Text('Hábito de lectura'),
                trailing: Text(goal),
                onTap: saved == null
                    ? null
                    : () => context.push('/onboarding?editar=1'),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Generar lecturas de ejemplo'),
                subtitle: const Text(
                  'Desde hoy, un mes y medio atrás, de 0 a 15 minutos.',
                ),
                onTap: () => _addSampleReadings(context, ref),
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

  Future<void> _addSampleReadings(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar lecturas de ejemplo'),
        content: const Text(
          'Se agregará una lectura al azar por cada día, desde hoy hasta un mes y medio atrás. Cada una dura entre 0 y 15 minutos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final count = await ref.read(bookRepositoryProvider).addSampleReadings();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se agregaron $count lecturas de ejemplo.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron generar las lecturas.')),
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
