const _notificationLocations = {'/discover', '/library', '/time', '/profile'};

/// In-app path carried by a local notification, or null when [payload] is not
/// one of the app's screens.
String? notificationLocation(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  final uri = Uri.tryParse(payload);
  if (uri == null || uri.hasScheme || uri.host.isNotEmpty) return null;
  if (uri.hasQuery || uri.hasFragment) return null;
  if (_notificationLocations.contains(uri.path)) return uri.path;
  final book = RegExp(r'^/read/(\d+)$').firstMatch(uri.path);
  if (book == null) return null;
  final id = int.parse(book.group(1)!);
  if (id <= 0) return null;
  return '/read/$id';
}

/// What to do with a tapped notification given onboarding and the current path.
///
/// [onboardingCompleted] null means the profile is still loading.
NotificationTap resolveNotificationTap({
  required bool? onboardingCompleted,
  required String? pendingLocation,
  required String currentPath,
  bool notificationsPrompted = true,
}) {
  if (pendingLocation == null) return const NotificationTap.drop();
  if (onboardingCompleted != true) return const NotificationTap.wait();
  if (!notificationsPrompted) return const NotificationTap.wait();
  final destination = notificationLocation(pendingLocation);
  if (destination == null || destination == currentPath) {
    return const NotificationTap.drop();
  }
  return NotificationTap.open(destination);
}

/// Route to open when onboarding finishes while a notification is waiting.
String notificationLanding({
  required bool editing,
  required String? pendingLocation,
}) {
  return notificationLocation(pendingLocation) ??
      (editing ? '/profile' : '/library');
}

class NotificationTap {
  const NotificationTap.wait() : location = null, waiting = true;

  const NotificationTap.drop() : location = null, waiting = false;

  const NotificationTap.open(this.location) : waiting = false;

  final String? location;
  final bool waiting;

  bool get opens => location != null;
}
