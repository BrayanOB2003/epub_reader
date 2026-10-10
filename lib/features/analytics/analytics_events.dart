import 'package:flutter/widgets.dart';

const tutorialBeginEvent = 'tutorial_begin';
const tutorialCompleteEvent = 'tutorial_complete';
const notificationPermissionEvent = 'notification_permission';
const bookAddedEvent = 'book_added';
const readingSessionEvent = 'reading_session';
const dailyGoalReachedEvent = 'daily_goal_reached';
const focusModeSetEvent = 'focus_mode_set';
const notificationOpenEvent = 'notification_open';

const bookSourceImport = 'import';
const bookSourceCatalog = 'catalog';
const bookResultImported = 'imported';
const bookResultAlreadyInLibrary = 'already_in_library';
const bookResultInvalid = 'invalid';

const readingSourceLibrary = 'library';
const readingSourceCatalog = 'catalog';
const readingSourceNotification = 'notification';

const notificationResultGranted = 'granted';
const notificationResultDenied = 'denied';
const notificationResultSkipped = 'skipped';

const _readingSources = {
  readingSourceLibrary,
  readingSourceCatalog,
  readingSourceNotification,
};

String readingSessionSource(String? value) {
  if (value != null && _readingSources.contains(value)) return value;
  return readingSourceLibrary;
}

String readingRoute(int bookId, String source) {
  return '/read/$bookId?origen=${readingSessionSource(source)}';
}

/// A notification path that opens the reader, marked so the session is not
/// counted as a library open. Other paths stay unchanged.
String routeOpenedFromNotification(String location) {
  if (RegExp(r'^/read/\d+$').hasMatch(location)) {
    return '$location?origen=$readingSourceNotification';
  }
  return location;
}

String notificationOpenDestination(String location) {
  if (location.startsWith('/read/')) return 'read';
  const names = {
    '/discover': 'discover',
    '/library': 'library',
    '/time': 'time',
    '/profile': 'profile',
  };
  return names[location] ?? 'library';
}

/// Screen name for Analytics. A book id in `/read/12` stays on the device.
String? analyticsScreenName(RouteSettings settings) {
  final name = settings.name;
  if (name == null || name.isEmpty) return null;
  final path = name.split('?').first;
  if (path == 'read' || path.startsWith('/read')) return 'read';
  if (!path.startsWith('/')) return path;
  final trimmed = path.substring(1);
  if (trimmed.isEmpty) return null;
  return trimmed.split('/').first;
}
