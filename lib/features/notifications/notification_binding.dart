import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts local notifications and opens the route stored in a tap.
class NotificationBinding extends ConsumerStatefulWidget {
  const NotificationBinding({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationBinding> createState() =>
      _NotificationBindingState();
}

class _NotificationBindingState extends ConsumerState<NotificationBinding> {
  var _applyScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(localNotificationsProvider)
          .start(
            channelName: l10n.notificationChannelName,
            channelDescription: l10n.notificationChannelDescription,
          );
    } catch (error) {
      debugPrint('[notifications] $error');
    }
  }

  void _scheduleApply() {
    if (_applyScheduled) return;
    _applyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyScheduled = false;
      if (!mounted) return;
      _apply();
    });
  }

  void _apply() {
    final status = ref.read(onboardingControllerProvider);
    final bool? completed = status.isLoading
        ? null
        : status.hasError
        ? false
        : status.value;
    final pending = ref.read(pendingNotificationLocationProvider);
    final current = ref.read(appRouterProvider).state.uri.path;
    final profile = ref.read(readerProfileProvider);
    final prompted = profile.hasError
        ? true
        : (profile.isLoading || !profile.hasValue)
        ? false
        : profile.requireValue?.notificationsPrompted ?? false;
    final tap = resolveNotificationTap(
      onboardingCompleted: completed,
      pendingLocation: pending,
      currentPath: current,
      notificationsPrompted: prompted,
    );
    if (tap.waiting) return;
    ref.read(pendingNotificationLocationProvider.notifier).clear();
    final location = tap.location;
    if (location == null) return;
    ref.read(appRouterProvider).go(location);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingNotificationLocationProvider, (_, _) => _scheduleApply());
    ref.listen(onboardingControllerProvider, (_, _) => _scheduleApply());
    ref.listen(readerProfileProvider, (_, _) => _scheduleApply());
    return widget.child;
  }
}
