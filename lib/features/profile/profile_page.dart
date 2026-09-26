import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(readerProfileProvider);
    final theme = Theme.of(context);

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
          if (saved == null) {
            return const Center(
              child: Text('Todavía no hay una meta de lectura.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Meta de lectura diaria',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Cuánto quieres leer cada día.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<int>(
                groupValue: saved.dailyGoalMinutes,
                onChanged: (minutes) => _saveGoal(context, ref, minutes),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final minutes in readingGoalMinutes)
                        RadioListTile<int>(
                          title: Text('$minutes minutos'),
                          value: minutes,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveGoal(
    BuildContext context,
    WidgetRef ref,
    int? minutes,
  ) async {
    if (minutes == null || !readingGoalMinutes.contains(minutes)) return;
    try {
      await ref.read(readerProfileStoreProvider).updateDailyGoal(minutes);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la meta de lectura.')),
      );
    }
  }
}
