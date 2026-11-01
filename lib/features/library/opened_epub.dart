import 'dart:async';
import 'dart:io';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/router.dart';
import 'package:epub_reader/features/analytics/analytics_events.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/features/library/data/epub_importer.dart';
import 'package:epub_reader/features/library/data/epub_metadata.dart';
import 'package:epub_reader/features/notifications/notification_prompt.dart';
import 'package:epub_reader/features/onboarding/onboarding_controller.dart';
import 'package:epub_reader/features/profile/reader_profile_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class OpenedEpub {
  const OpenedEpub({required this.path, required this.name});

  final String path;
  final String name;
}

const openedEpubChannel = EventChannel('com.somosliora.app/open_epub');

bool get openedEpubListeningEnabled {
  if (kIsWeb) return false;
  if (Platform.environment['FLUTTER_TEST'] == 'true') return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

Stream<OpenedEpub> openedEpubEvents() {
  return openedEpubChannel.receiveBroadcastStream().map((event) {
    final file = openedEpubFromEvent(event);
    if (file == null) {
      throw const FormatException('opened epub');
    }
    return file;
  });
}

OpenedEpub? openedEpubFromEvent(Object? event) {
  if (event is! Map) return null;
  final path = event['path'];
  if (path is! String || path.isEmpty) return null;
  final name = event['name'];
  final fileName = name is String && name.trim().isNotEmpty
      ? name.trim()
      : p.basename(path);
  return OpenedEpub(path: path, name: fileName);
}

/// The reader waits until onboarding and the notification prompt are out of
/// the way, so a cold start does not lose the book behind `/boot`.
bool canOpenBookFromDevice({
  required bool? onboardingComplete,
  required String location,
  required bool notificationPromptDue,
  bool permissionKnown = true,
}) {
  if (onboardingComplete != true) return false;
  if (!permissionKnown) return false;
  if (location == '/boot' ||
      location == '/onboarding' ||
      location == '/notifications') {
    return false;
  }
  if (notificationPromptDue) return false;
  return true;
}

class OpenedEpubBinding extends ConsumerStatefulWidget {
  const OpenedEpubBinding({required this.child, this.events, super.key});

  final Widget child;
  final Stream<OpenedEpub>? events;

  @override
  ConsumerState<OpenedEpubBinding> createState() => _OpenedEpubBindingState();
}

class _OpenedEpubBindingState extends ConsumerState<OpenedEpubBinding> {
  StreamSubscription<OpenedEpub>? _subscription;
  Future<void> _queue = Future<void>.value();
  final _handled = <String>{};
  late final GoRouter _router;
  int? _pendingBookId;
  var _openScheduled = false;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    _router.routerDelegate.addListener(_scheduleOpen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stream =
          widget.events ??
          (openedEpubListeningEnabled ? openedEpubEvents() : null);
      if (stream == null) return;
      _subscription = stream.listen(_enqueue, onError: _onStreamError);
    });
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_scheduleOpen);
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _scheduleOpen() {
    if (_pendingBookId == null || _openScheduled) return;
    _openScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScheduled = false;
      if (!mounted) return;
      _openPending();
    });
  }

  void _openPending() {
    final bookId = _pendingBookId;
    if (bookId == null || !_canOpenReader()) return;
    _pendingBookId = null;
    _router.push(readingRoute(bookId, readingSourceOpened));
  }

  void _onStreamError(Object error, StackTrace stack) {
    unawaited(
      ref
          .read(appAnalyticsProvider)
          .recordUnexpected('open_epub_failed', stack),
    );
  }

  void _enqueue(OpenedEpub file) {
    if (!_handled.add(file.path)) return;
    _queue = _queue.then((_) => _import(file));
  }

  Future<void> _import(OpenedEpub file) async {
    final analytics = ref.read(appAnalyticsProvider);
    try {
      final bytes = await File(file.path).readAsBytes();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final fallback = p.basenameWithoutExtension(file.name).trim();
      final result = await ref
          .read(epubImporterProvider)
          .importBytes(
            bytes,
            fallbackTitle: fallback.isEmpty ? l10n.untitled : fallback,
          );
      await analytics.logBookAdded(
        source: bookSourceOpened,
        result: result.outcome == ImportOutcome.alreadyInLibrary
            ? bookResultAlreadyInLibrary
            : bookResultImported,
      );
      if (!mounted) return;
      _pendingBookId = result.bookId;
      _openPending();
    } on EpubFormatException catch (error) {
      await analytics.logBookAdded(
        source: bookSourceOpened,
        result: bookResultInvalid,
      );
      if (!mounted) return;
      _showMessage(_message(AppLocalizations.of(context), error));
    } catch (_, stack) {
      await analytics.recordUnexpected('open_epub_failed', stack);
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).importFailed);
    } finally {
      try {
        final cached = File(file.path);
        if (cached.existsSync()) await cached.delete();
      } catch (_) {}
    }
  }

  bool _canOpenReader() {
    final status = ref.read(onboardingControllerProvider);
    final profile = ref.read(readerProfileProvider);
    final shown =
        ref.read(notificationPromptShownProvider) ??
        profile.asData?.value?.notificationPromptSkippedOn;
    final granted = ref.read(notificationPermissionGrantedProvider);
    return canOpenBookFromDevice(
      onboardingComplete: status.isLoading ? null : status.asData?.value,
      location: _router.state.uri.path,
      permissionKnown: granted != null,
      notificationPromptDue: notificationPromptDue(
        permissionGranted: granted,
        shownOn: shown,
        now: DateTime.now(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  String _message(AppLocalizations l10n, EpubFormatException error) {
    return switch (error.failure) {
      EpubFormatFailure.notEpub => l10n.notAnEpub,
      EpubFormatFailure.missingRoot => l10n.epubMissingRoot,
      EpubFormatFailure.missingContent => l10n.epubMissingContent,
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingControllerProvider, (_, _) => _scheduleOpen());
    ref.listen(readerProfileProvider, (_, _) => _scheduleOpen());
    ref.listen(
      notificationPermissionGrantedProvider,
      (_, _) => _scheduleOpen(),
    );
    ref.listen(notificationPromptShownProvider, (_, _) => _scheduleOpen());
    return widget.child;
  }
}
