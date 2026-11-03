import 'package:flutter/services.dart';

const premiumEnvAsset = '.env/.env';
const revenueCatIosKeyName = 'REVENUECAT_KEY_IOS';
const revenueCatAndroidKeyName = 'REVENUECAT_KEY_ANDROID';

/// The value of [name] in a `NAME: value` or `NAME=value` env file, or null.
String? envValue(String raw, String name) {
  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final colon = trimmed.indexOf(':');
    final equals = trimmed.indexOf('=');
    final separator = colon < 0
        ? equals
        : equals < 0
        ? colon
        : (colon < equals ? colon : equals);
    if (separator <= 0) continue;
    if (trimmed.substring(0, separator).trim() != name) continue;
    final value = trimmed.substring(separator + 1).trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

/// The public RevenueCat SDK key for [platform], or null when the platform has
/// no store or the key is missing from the env file.
Future<String?> loadRevenueCatKey(
  TargetPlatform platform, {
  AssetBundle? bundle,
}) async {
  final name = switch (platform) {
    TargetPlatform.iOS => revenueCatIosKeyName,
    TargetPlatform.android => revenueCatAndroidKeyName,
    _ => null,
  };
  if (name == null) return null;
  final raw = await (bundle ?? rootBundle).loadString(premiumEnvAsset);
  return envValue(raw, name);
}
