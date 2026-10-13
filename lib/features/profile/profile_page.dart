import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/focus/focus_mode_tile.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/reader/quote_highlight_default_tile.dart';
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
            final colors = ScheduleColors.of(context);
            final goal = saved == null
                ? l10n.notSet
                : l10n.minutes(saved.dailyGoalMinutes);
            final quoteCount = ref
                .watch(savedQuotesProvider)
                .asData
                ?.value
                .length;
            final reviewed = ref.watch(readingSessionsProvider).asData?.value;
            final reviewTitle = _reviewTitle(context, l10n, reviewed);
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
                  title: Text(reviewTitle),
                  onTap: () => context.push('/profile/month'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.savedQuotes),
                  trailing: quoteCount == null
                      ? null
                      : Text(
                          '$quoteCount',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: colors.muted),
                        ),
                  onTap: () => context.push('/quotes'),
                ),
                const ScheduleRule(),
                const QuoteHighlightDefaultTile(),
                const Divider(height: 1),
                if (saved != null &&
                    ref.watch(focusModeControllerProvider).offered)
                  const FocusModeTile(),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sampleReadingsFailed)));
    }
  }
}

String _reviewTitle(
  BuildContext context,
  AppLocalizations l10n,
  List<ReadingSession>? sessions,
) {
  if (sessions == null) return l10n.monthReading;
  final month = monthOnReview(sessions: sessions, now: DateTime.now());
  if (month == null) return l10n.monthReading;
  final code = Localizations.localeOf(context).languageCode;
  final name = code == 'en'
      ? scheduleMonthTitle(month.month, code)
      : scheduleMonthName(month.month, code);
  return l10n.monthReadingOf(name);
}
