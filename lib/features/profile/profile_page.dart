import 'package:epub_reader/app/app_logo.dart';
import 'package:epub_reader/app/app_theme_store.dart';
import 'package:epub_reader/app/platform_dialog.dart';
import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/core/database/app_database.dart';
import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/focus/focus_mode_tile.dart';
import 'package:epub_reader/features/habits/month_reading.dart';
import 'package:epub_reader/features/onboarding/onboarding_answers.dart';
import 'package:epub_reader/features/profile/appearance_page.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/features/profile/reading_routine.dart';
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
          error: (error, _) => const _ProfileLoadFailed(),
          data: (saved) => _ProfileList(saved: saved),
        ),
      ),
    );
  }
}

class _ProfileLoadFailed extends StatelessWidget {
  const _ProfileLoadFailed();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        ScheduleHeader(title: l10n.profile),
        const ScheduleRule(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ScheduleIssue(message: l10n.profileLoadFailed),
        ),
      ],
    );
  }
}

class _ProfileList extends ConsumerWidget {
  const _ProfileList({required this.saved});

  final ReaderProfile? saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final quoteCount = ref.watch(savedQuotesProvider).asData?.value.length;
    final reviewed = ref.watch(readingSessionsProvider).asData?.value;
    final sampleCount =
        ref.watch(sampleSessionCountProvider).asData?.value ?? 0;
    final goal = saved == null
        ? l10n.notSet
        : l10n.minutes(saved!.dailyGoalMinutes);
    final habit = saved == null
        ? null
        : OnboardingAnswers.fromStored(
            motivations: saved!.motivations,
            dailyGoalMinutes: saved!.dailyGoalMinutes,
            routine: saved!.routine,
            routineHour: saved!.routineHour,
            routineDays: saved!.routineDays,
          );
    final muted = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: colors.muted,
    );
    return ListView(
      children: [
        ScheduleHeader(title: l10n.profile),
        const ScheduleRule(),
        _ProfileRow(
          title: l10n.readingHabit,
          subtitle: habit == null
              ? null
              : habitScheduleLine(
                  l10n,
                  period: habit.routine,
                  hour: habit.routineHour,
                  days: habit.weekdays,
                ),
          trailing: goal,
          trailingStyle: muted,
          onTap: saved == null ? null : () => context.push('/profile/habit'),
        ),
        _GroupLabel(title: l10n.profileRecords),
        _ProfileRow(
          title: _reviewTitle(context, l10n, reviewed),
          onTap: () => context.push('/profile/month'),
        ),
        const Divider(height: 1),
        _ProfileRow(
          title: l10n.savedQuotes,
          trailing: quoteCount == null ? null : '$quoteCount',
          trailingStyle: muted,
          onTap: () => context.push('/profile/quotes'),
        ),
        _GroupLabel(title: l10n.profileDevice),
        _ProfileRow(
          title: l10n.appearance,
          trailing: themeLabel(
            l10n,
            ref.watch(appThemeProvider).asData?.value ?? AppThemeId.programa,
          ),
          trailingStyle: muted,
          onTap: () => context.push('/profile/appearance'),
        ),
        const Divider(height: 1),
        const QuoteHighlightDefaultTile(),
        const Divider(height: 1),
        if (saved != null && ref.watch(focusModeControllerProvider).offered)
          const FocusModeTile(),
        _ProfileRow(
          title: l10n.pqrs,
          onTap: () => context.push('/profile/pqrs'),
        ),
        _GroupLabel(title: l10n.profileSampleData),
        _ProfileRow(
          title: l10n.sampleReadings,
          subtitle: l10n.sampleReadingsSubtitle,
          onTap: () => _addSampleReadings(context, ref),
        ),
        if (sampleCount > 0) ...[
          const Divider(height: 1),
          _ProfileRow(
            title: l10n.removeSampleReadings,
            subtitle: l10n.sampleReadingsPresent(sampleCount),
            onTap: () => _removeSampleReadings(context, ref),
          ),
        ],
        const _AppNameplate(),
      ],
    );
  }

  Future<void> _addSampleReadings(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final continued = await showPlatformConfirm(
      context,
      title: l10n.sampleReadings,
      message: l10n.sampleReadingsBody,
      confirm: l10n.sampleReadingsContinue,
      cancel: l10n.cancel,
    );
    if (!continued || !context.mounted) return;
    final write = await showPlatformConfirm(
      context,
      title: l10n.sampleReadingsConfirmTitle,
      message: l10n.sampleReadingsConfirmBody,
      confirm: l10n.sampleReadingsWrite,
      cancel: l10n.cancel,
      destructive: true,
    );
    if (!write || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await ref
          .read(bookRepositoryProvider)
          .addSampleReadings(sampleTitle: l10n.sampleBookTitle);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sampleReadingsAdded(count))),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.sampleReadingsFailed)));
    }
  }

  Future<void> _removeSampleReadings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showPlatformConfirm(
      context,
      title: l10n.removeSampleReadings,
      message: l10n.removeSampleReadingsBody,
      confirm: l10n.removeSampleReadingsAction,
      cancel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(bookRepositoryProvider).removeSampleReadings();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sampleReadingsRemoved)),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sampleReadingsRemoveFailed)),
      );
    }
  }
}

class _AppNameplate extends StatelessWidget {
  const _AppNameplate();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
      child: Row(
        children: [
          const AppLogo(size: 36),
          const SizedBox(width: 12),
          Text(
            'Liora',
            style: programTitle(
              context,
              ScheduleColors.of(context).station,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ScheduleColors.of(context).muted,
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.trailingStyle,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final TextStyle? trailingStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = trailing;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      enabled: onTap != null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: trailingStyle),
          if (onTap != null) ...[
            if (value != null) const SizedBox(width: 4),
            const ScheduleDisclosure(),
          ],
        ],
      ),
      onTap: onTap,
    );
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
