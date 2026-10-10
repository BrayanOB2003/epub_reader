import 'dart:async';

import 'package:epub_reader/features/focus/focus_mode.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const focusModeTileKey = ValueKey('focus-mode');

/// Profile switch. Android asks for Do Not Disturb access. iOS opens the
/// Shortcuts guide and only turns on after the reader taps Done.
class FocusModeTile extends ConsumerStatefulWidget {
  const FocusModeTile({super.key});

  @override
  ConsumerState<FocusModeTile> createState() => _FocusModeTileState();
}

class _FocusModeTileState extends ConsumerState<FocusModeTile>
    with WidgetsBindingObserver {
  var _busy = false;
  var _awaitingAccess = false;
  var _leftForAccess = false;
  var _resolvingAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_awaitingAccess) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _leftForAccess = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _leftForAccess) {
      _leftForAccess = false;
      unawaited(_finishAccessRequest());
    }
  }

  Future<void> _set(bool value) async {
    if (_busy) return;
    final controller = ref.read(focusModeControllerProvider);
    final l10n = AppLocalizations.of(context);
    if (controller.guidesWithShortcuts) {
      if (value) {
        context.push('/focus');
        return;
      }
      final saved = await _write(false);
      if (!mounted || !saved) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.focusModeIosRemains)));
      return;
    }

    setState(() => _busy = true);
    try {
      if (!value) {
        await ref.read(readerProfileStoreProvider).setFocusMode(false);
        return;
      }
      if (await controller.hasAccess()) {
        await ref.read(readerProfileStoreProvider).setFocusMode(true);
        return;
      }
      _awaitingAccess = true;
      final opened = await controller.openAccessSettings();
      if (!mounted) return;
      if (!opened) {
        _awaitingAccess = false;
        _message(l10n.focusModeChangeFailed);
      }
    } catch (_) {
      _awaitingAccess = false;
      if (mounted) _message(l10n.focusModeChangeFailed);
    } finally {
      if (mounted && !_resolvingAccess) setState(() => _busy = false);
    }
  }

  Future<void> _finishAccessRequest() async {
    if (!_awaitingAccess || _resolvingAccess) return;
    _awaitingAccess = false;
    _resolvingAccess = true;
    if (!mounted) {
      _resolvingAccess = false;
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final access = await ref.read(focusModeControllerProvider).hasAccess();
      if (!mounted) return;
      if (access) {
        await ref.read(readerProfileStoreProvider).setFocusMode(true);
      } else {
        _message(l10n.focusModePermissionNeeded);
      }
    } catch (_) {
      if (mounted) _message(l10n.focusModeChangeFailed);
    } finally {
      _resolvingAccess = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _write(bool enabled) async {
    setState(() => _busy = true);
    try {
      await ref.read(readerProfileStoreProvider).setFocusMode(enabled);
      return true;
    } catch (_) {
      if (mounted) {
        _message(AppLocalizations.of(context).focusModeChangeFailed);
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled =
        ref.watch(readerProfileProvider).asData?.value?.focusMode ?? false;
    final controller = ref.watch(focusModeControllerProvider);
    final subtitle = controller.guidesWithShortcuts
        ? (enabled ? l10n.focusModeIosOnBody : l10n.focusModeIosBody)
        : l10n.focusModeAndroidBody;
    return Column(
      children: [
        SwitchListTile.adaptive(
          key: focusModeTileKey,
          title: Text(l10n.focusMode),
          subtitle: Text(subtitle),
          value: enabled,
          onChanged: _busy ? null : _set,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
