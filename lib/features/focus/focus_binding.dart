import 'dart:async';

import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/focus/focus_session.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Turns Android Do Not Disturb on while Liora is in front, when focus mode
/// is enabled and the reader has granted access.
class FocusBinding extends ConsumerStatefulWidget {
  const FocusBinding({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FocusBinding> createState() => _FocusBindingState();
}

class _FocusBindingState extends ConsumerState<FocusBinding>
    with WidgetsBindingObserver {
  final _session = FocusSession();
  late final FocusModeController _controller;
  Future<void> _tail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _controller = ref.read(focusModeControllerProvider);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enqueue();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_session.holding && _controller.controlsDoNotDisturb) {
      unawaited(_controller.disable());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _enqueue();
  }

  void _enqueue() {
    _tail = _tail.catchError((Object _) {}).then((_) => _sync());
  }

  Future<void> _sync() async {
    if (!mounted || !_controller.controlsDoNotDisturb) return;
    final enabled =
        ref.read(readerProfileProvider).asData?.value?.focusMode ?? false;
    var access = false;
    if (enabled || _session.holding) {
      access = await _controller.hasAccess();
      if (!mounted) return;
    }
    final enabledNow =
        ref.read(readerProfileProvider).asData?.value?.focusMode ?? false;
    final action = _session.next(
      shouldHold: focusShouldHold(
        enabled: enabledNow && access,
        lifecycle: WidgetsBinding.instance.lifecycleState,
      ),
    );
    if (action == null) return;
    if (action == FocusAction.disable && !access) {
      _session.commit(action);
      return;
    }
    final ok = switch (action) {
      FocusAction.enable => await _controller.enable(),
      FocusAction.disable => await _controller.disable(),
    };
    if (!mounted) {
      if (ok && action == FocusAction.enable) {
        await _controller.disable();
      }
      return;
    }
    if (ok) _session.commit(action);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(readerProfileProvider, (_, _) => _enqueue());
    return widget.child;
  }
}
