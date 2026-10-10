import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const focusModeChannelName = 'com.somosliora.app/focus';

/// Android can turn Do Not Disturb on. iOS can only open Shortcuts.
class FocusModeController {
  const FocusModeController();

  static const _channel = MethodChannel(focusModeChannelName);

  bool get controlsDoNotDisturb =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get guidesWithShortcuts =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get offered => controlsDoNotDisturb || guidesWithShortcuts;

  Future<bool> hasAccess() => _call('hasAccess');

  Future<bool> openAccessSettings() => _call('openSettings');

  Future<bool> enable() => _call('enable');

  Future<bool> disable() => _call('disable');

  Future<bool> openShortcuts() => _call('openShortcuts');

  Future<bool> _call(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final focusModeControllerProvider = Provider<FocusModeController>((ref) {
  return const FocusModeController();
});
