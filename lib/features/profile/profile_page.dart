import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(readerProfileProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context).profileLoadFailed('$error'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (saved) {
            final l10n = AppLocalizations.of(context);
            final goal = saved == null
                ? l10n.notSet
                : l10n.minutes(saved.dailyGoalMinutes);
            return ListView(
              children: [
                ScheduleHeader(title: l10n.profile),
                const ScheduleRule(),
                ListTile(
                  title: Text(l10n.readingHabit),
                  trailing: Text(goal),
                  onTap: saved == null
                      ? null
                      : () => context.push('/onboarding?editar=1'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.sampleReadings),
                  subtitle: Text(l10n.sampleReadingsSubtitle),
                  onTap: () => _addSampleReadings(context, ref),
                ),
                const Divider(height: 1),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addSampleReadings(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sampleReadings),
        content: Text(l10n.sampleReadingsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.generate),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final count = await ref
          .read(bookRepositoryProvider)
          .addSampleReadings(sampleTitle: l10n.sampleBookTitle);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sampleReadingsAdded(count))));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.sampleReadingsFailed)));
    }
  }
}
