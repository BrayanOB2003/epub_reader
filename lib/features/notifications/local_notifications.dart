import 'dart:async';

import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/features/notifications/notification_destination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const notificationChannelId = 'liora';

/// A local notification. [location] is an in-app path such as `/library`
/// or `/read/3`. A tap opens that path.
class LocalNotificationMessage {
  const LocalNotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.location,
  });

  final int id;
  final String title;
  final String body;
  final String location;
}

abstract class LocalNotifications {
  Future<void> start({
    required String channelName,
    required String channelDescription,
  });

  Future<bool> requestPermission();

  /// Whether the system currently allows notifications.
  /// Desktop and tests report true so the prompt is not shown there.
  Future<bool> hasPermission();

  /// Shows [message] and asks for permission the first time.
  /// Returns false when the platform cannot show it or permission is denied.
  Future<bool> show(LocalNotificationMessage message);

  /// Schedules [message] at [when]. Does not ask for permission.
  Future<bool> schedule({
    required LocalNotificationMessage message,
    required DateTime when,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

final pendingNotificationLocationProvider =
    NotifierProvider<PendingNotificationLocation, String?>(
      PendingNotificationLocation.new,
    );

class PendingNotificationLocation extends Notifier<String?> {
  @override
  String? build() => null;

  void open(String location) {
    final destination = notificationLocation(location);
    if (destination == null || destination == state) return;
    state = destination;
    unawaited(
      ref
          .read(appAnalyticsProvider)
          .logNotificationOpen(notificationOpenDestination(destination)),
    );
  }

  void clear() {
    if (state == null) return;
    state = null;
  }
}

final localNotificationsProvider = Provider<LocalNotifications>((ref) {
  return createLocalNotifications(
    onOpened: (location) {
      ref.read(pendingNotificationLocationProvider.notifier).open(location);
    },
  );
});

LocalNotifications createLocalNotifications({
  required void Function(String location) onOpened,
}) {
  if (kIsWeb || _runningWidgetTest) return const SilentLocalNotifications();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS => PluginLocalNotifications(onOpened: onOpened),
    _ => const SilentLocalNotifications(),
  };
}

/// Widget tests have no notification plugin. The binding's runtime type is
/// `AutomatedTestWidgetsFlutterBinding` or `LiveTestWidgetsFlutterBinding`.
bool get _runningWidgetTest {
  final binding = WidgetsBinding.instance.runtimeType.toString();
  return binding.contains('TestWidgetsFlutterBinding');
}

class SilentLocalNotifications implements LocalNotifications {
  const SilentLocalNotifications();

  @override
  Future<void> start({
    required String channelName,
    required String channelDescription,
  }) async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> show(LocalNotificationMessage message) async => false;

  @override
  Future<bool> schedule({
    required LocalNotificationMessage message,
    required DateTime when,
  }) async => false;

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

class PluginLocalNotifications implements LocalNotifications {
  PluginLocalNotifications({
    required this.onOpened,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final void Function(String location) onOpened;
  final FlutterLocalNotificationsPlugin _plugin;

  var _started = false;
  var _timeZoneReady = false;
  var _channelName = 'Liora';
  var _channelDescription = 'Liora';

  @override
  Future<void> start({
    required String channelName,
    required String channelDescription,
  }) async {
    _channelName = channelName;
    _channelDescription = channelDescription;
    if (_started) return;
    await _ensureTimeZone();
    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
    );
    _started = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _emit(launch?.notificationResponse?.payload);
    }
  }

  @override
  Future<bool> requestPermission() async {
    _ensureStarted();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    _ensureStarted();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final status = await ios?.checkPermissions();
    return status?.isEnabled ?? false;
  }

  @override
  Future<bool> show(LocalNotificationMessage message) async {
    final location = _locationOf(message);
    if (!await requestPermission()) return false;
    await _plugin.show(
      id: message.id,
      title: message.title,
      body: message.body,
      notificationDetails: _details(),
      payload: location,
    );
    return true;
  }

  @override
  Future<bool> schedule({
    required LocalNotificationMessage message,
    required DateTime when,
  }) async {
    final location = _locationOf(message);
    if (!when.isAfter(DateTime.now())) return false;
    if (!await hasPermission()) return false;
    await _ensureTimeZone();
    await _plugin.zonedSchedule(
      id: message.id,
      title: message.title,
      body: message.body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: location,
    );
    return true;
  }

  NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        _channelName,
        channelDescription: _channelDescription,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
  }

  Future<void> _ensureTimeZone() async {
    if (_timeZoneReady) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (error) {
      debugPrint('[notifications] timezone $error');
    }
    _timeZoneReady = true;
  }

  @override
  Future<void> cancel(int id) {
    _ensureStarted();
    return _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() {
    _ensureStarted();
    return _plugin.cancelAll();
  }

  void _onResponse(NotificationResponse response) {
    _emit(response.payload);
  }

  void _emit(String? payload) {
    final location = notificationLocation(payload);
    if (location != null) onOpened(location);
  }

  String _locationOf(LocalNotificationMessage message) {
    final location = notificationLocation(message.location);
    if (location == null) {
      throw ArgumentError.value(
        message.location,
        'location',
        'La ruta no es una pantalla de la app.',
      );
    }
    return location;
  }

  void _ensureStarted() {
    if (_started) return;
    throw StateError('Las notificaciones todavía no están listas.');
  }
}
