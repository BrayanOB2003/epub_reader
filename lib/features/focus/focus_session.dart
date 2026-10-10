import 'package:flutter/widgets.dart';

/// What the Android side should do to match the reader's focus setting.
enum FocusAction { enable, disable }

/// True while Liora is in front and focus mode should keep the phone quiet.
///
/// [AppLifecycleState.inactive] still counts: the shade and the app switcher
/// should not drop Do Not Disturb for a moment.
bool focusShouldHold({
  required bool enabled,
  required AppLifecycleState? lifecycle,
}) {
  if (!enabled) return false;
  return switch (lifecycle) {
    AppLifecycleState.hidden ||
    AppLifecycleState.paused ||
    AppLifecycleState.detached => false,
    AppLifecycleState.resumed || AppLifecycleState.inactive || null => true,
  };
}

/// Remembers whether this process currently owns the silence, so a repeated
/// resume does not set Do Not Disturb again.
class FocusSession {
  var holding = false;

  FocusAction? next({required bool shouldHold}) {
    if (shouldHold && !holding) return FocusAction.enable;
    if (!shouldHold && holding) return FocusAction.disable;
    return null;
  }

  void commit(FocusAction action) {
    holding = action == FocusAction.enable;
  }
}
