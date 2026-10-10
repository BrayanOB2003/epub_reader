import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Asks for notification permission once, after the first onboarding.
class NotificationPermissionPage extends ConsumerStatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  ConsumerState<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends ConsumerState<NotificationPermissionPage> {
  var _busy = false;

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(localNotificationsProvider).requestPermission();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).notificationPermissionFailed,
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    await _continue();
  }

  Future<void> _skip() async {
    if (_busy) return;
    setState(() => _busy = true);
    await _continue();
  }

  Future<void> _continue() async {
    final pending = ref.read(pendingNotificationLocationProvider);
    ref.read(pendingNotificationLocationProvider.notifier).clear();
    await ref.read(readerProfileStoreProvider).markNotificationsPrompted();
    if (!mounted) return;
    context.go(notificationLanding(editing: false, pendingLocation: pending));
  }

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      ColoredBox(
                        color: colors.station,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 16, 20),
                          child: Text(
                            l10n.notificationPermissionTitle,
                            style: programTitle(colors.onStation, size: 44),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.notificationPermissionBody,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ScheduleAction(
                  label: l10n.notificationPermissionAllow,
                  onPressed: _busy ? null : _allow,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(l10n.notificationPermissionSkip),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
