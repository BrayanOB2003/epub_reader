import 'package:flutter/foundation.dart';

/// Remote Config `min_app_version`. The build after `+`. `5` and `1.2.0+5`
/// both mean build 5. A lower build has to update.
const minAppVersionKey = 'min_app_version';

const androidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.somosliora.app';

/// The App Store page. Empty until that listing exists.
const iosStoreUrl = '';

const _storeSchemes = {'http', 'https', 'itms-apps', 'market'};

/// The minimum build read from Remote Config.
class AppUpdatePolicy {
  const AppUpdatePolicy({required this.minimumVersion});

  const AppUpdatePolicy.empty() : minimumVersion = '';

  final String minimumVersion;
}

/// Whether this install has to update, and where the store button goes.
class AppUpdateStatus {
  const AppUpdateStatus({required this.blocked, this.storeUrl});

  const AppUpdateStatus.clear() : blocked = false, storeUrl = null;

  final bool blocked;
  final Uri? storeUrl;
}

/// Reads the version gate. Tests substitute a value that never touches Firebase.
abstract interface class AppUpdateConfig {
  Future<AppUpdatePolicy> load();
}

/// The compilation build reported by the platform, such as `4`. Null when
/// that value is missing or not an integer.
String? appBuildLabel(String buildNumber) {
  return _integerText(buildNumber);
}

/// True when the installed build is lower than [minimum].
///
/// Only the number after `+` counts, so `1.0.0+1` is older than `1.0.0+2`
/// and the same as `1.0.1+1`. A plain number is that build. An empty or
/// unreadable value does not force an update.
bool versionIsBelow(String? installed, String minimum) {
  final current = _buildNumber(installed);
  final requiredBuild = _buildNumber(minimum);
  if (current == null || requiredBuild == null) return false;
  return current < requiredBuild;
}

/// A phone is blocked when its build is older. The store link can be missing;
/// the screen still covers the app and the button reports that it could not
/// open the store.
AppUpdateStatus decideAppUpdate({
  required String? installedVersion,
  required String minimumVersion,
  required TargetPlatform platform,
}) {
  if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
    return const AppUpdateStatus.clear();
  }
  if (!versionIsBelow(installedVersion, minimumVersion)) {
    return const AppUpdateStatus.clear();
  }
  return AppUpdateStatus(blocked: true, storeUrl: storeListingUri(platform));
}

/// The store page for [platform].
Uri? storeListingUri(TargetPlatform platform) {
  final raw = switch (platform) {
    TargetPlatform.iOS => iosStoreUrl,
    TargetPlatform.android => androidStoreUrl,
    _ => '',
  };
  return _storeUri(raw);
}

int? _buildNumber(String? raw) {
  final text = _buildText(raw);
  if (text == null) return null;
  return int.tryParse(text);
}

/// The integer after the last `+`. A string with no `+` counts only when it
/// is itself an integer, so a Remote Config value of `5` is build 5.
String? _buildText(String? raw) {
  if (raw == null) return null;
  final text = raw.trim();
  if (text.isEmpty) return null;
  final plus = text.lastIndexOf('+');
  final build = plus < 0 ? text : text.substring(plus + 1);
  return _integerText(build);
}

String? _integerText(String raw) {
  final value = _wholeNumber(raw);
  return value?.toString();
}

/// A Remote Config number often arrives as `4.0`. That is build 4.
int? _wholeNumber(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final whole = int.tryParse(text);
  if (whole != null) return whole;
  final decimal = double.tryParse(text);
  if (decimal == null || decimal != decimal.roundToDouble()) return null;
  return decimal.toInt();
}

Uri? _storeUri(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !_storeSchemes.contains(uri.scheme)) return null;
  if (uri.host.isEmpty) return null;
  return uri;
}
