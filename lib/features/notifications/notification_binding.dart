import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:epub_reader/features/notifications/reading_notification_scheduler.dart';

import 'dart:async';

import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:epub_reader/features/notifications/notification_prompt.dart';
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

class _NotificationBindingState extends ConsumerState<NotificationBinding>
    with WidgetsBindingObserver {
  var _applyScheduled = false;
  var _notificationsReady = false;
  var _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_onResumed());
  }

  Future<void> _onResumed() async {
    await ref.read(notificationPermissionGrantedProvider.notifier).refresh();
    if (!mounted) return;
    _showPromptIfDue();
    _scheduleRefresh();
  }

  void _showPromptIfDue() {
    final status = ref.read(onboardingControllerProvider);
    final completed =
        !status.isLoading && !status.hasError && status.value == true;
    if (!completed) return;
    final profile = ref.read(readerProfileProvider);
    final row = profile.asData?.value;
    final due = notificationPromptDue(
      permissionGranted: ref.read(notificationPermissionGrantedProvider),
      shownOn:
          ref.read(notificationPromptShownProvider) ??
          row?.notificationPromptSkippedOn,
      now: DateTime.now(),
    );
    if (!due) return;
    final path = ref.read(appRouterProvider).state.uri.path;
    if (path == '/notifications' || path == '/onboarding' || path == '/boot') {
      return;
    }
    final back = notificationLocation(path);
    final location = back == null
        ? '/notifications'
        : '/notifications?volver=${Uri.encodeQueryComponent(back)}';
    ref.read(appRouterProvider).go(location);
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
      return;
    }
    if (!mounted) return;
    _notificationsReady = true;
    await ref.read(notificationPermissionGrantedProvider.notifier).refresh();
    if (!mounted) return;
    await _refreshReadingNotifications();
  }

  void _scheduleRefresh() {
    if (!_notificationsReady || _refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted) return;
      unawaited(_refreshReadingNotifications());
    });
  }

  Future<void> _refreshReadingNotifications() async {
    if (!mounted || !_notificationsReady) return;
    final profile = ref.read(readerProfileProvider);
    final books = ref.read(booksProvider);
    final sessions = ref.read(readingSessionsProvider);
    if (!profile.hasValue || !books.hasValue || !sessions.hasValue) return;
    try {
      await ref
          .read(readingNotificationSchedulerProvider)
          .apply(
            l10n: AppLocalizations.of(context),
            profile: profile.value,
            books: books.value ?? const [],
            sessions: sessions.value ?? const [],
            permissionGranted: ref.read(notificationPermissionGrantedProvider),
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
    if (current == '/notifications') return;
    final profile = ref.read(readerProfileProvider);
    final row = profile.asData?.value;
    final due = notificationPromptDue(
      permissionGranted: ref.read(notificationPermissionGrantedProvider),
      shownOn:
          ref.read(notificationPromptShownProvider) ??
          row?.notificationPromptSkippedOn,
      now: DateTime.now(),
    );
    final prompted = !due;
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
    ref.read(appRouterProvider).go(routeOpenedFromNotification(location));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingNotificationLocationProvider, (_, _) => _scheduleApply());
    ref.listen(onboardingControllerProvider, (_, _) => _scheduleApply());
    ref.listen(readerProfileProvider, (_, _) {
      _scheduleApply();
      _scheduleRefresh();
    });
    ref.listen(booksProvider, (_, _) => _scheduleRefresh());
    ref.listen(readingSessionsProvider, (_, _) => _scheduleRefresh());
    ref.listen(
      notificationPermissionGrantedProvider,
      (_, _) => _scheduleRefresh(),
    );
    return widget.child;
  }
}
