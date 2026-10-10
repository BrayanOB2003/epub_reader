import 'package:epub_reader/features/notifications/local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local calendar day used to show the notification prompt once per day.
String notificationPromptDay(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// True when notifications are off and the prompt has not been shown today.
///
/// [permissionGranted] null means the system status is still unknown.
bool notificationPromptDue({
  required bool? permissionGranted,
  required String? shownOn,
  required DateTime now,
}) {
  if (permissionGranted != false) return false;
  return shownOn != notificationPromptDay(now);
}

/// Null until the system permission has been read.
final notificationPermissionGrantedProvider =
    NotifierProvider<NotificationPermissionGranted, bool?>(
      NotificationPermissionGranted.new,
    );

class NotificationPermissionGranted extends Notifier<bool?> {
  @override
  bool? build() => null;

  Future<void> refresh() async {
    try {
      final granted = await ref
          .read(localNotificationsProvider)
          .hasPermission();
      if (!ref.mounted || state == granted) return;
      state = granted;
    } catch (_) {
      if (!ref.mounted || state == false) return;
      state = false;
    }
  }
}

/// Day the prompt was shown in this process, before the database write returns.
final notificationPromptShownProvider =
    NotifierProvider<NotificationPromptShown, String?>(
      NotificationPromptShown.new,
    );

class NotificationPromptShown extends Notifier<String?> {
  @override
  String? build() => null;

  void mark(String day) {
    if (state == day) return;
    state = day;
  }
}
