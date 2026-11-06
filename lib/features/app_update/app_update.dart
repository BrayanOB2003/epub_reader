import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/app_update/app_version.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// The installed compilation build, such as `4`. Null when the platform cannot
/// answer, so the profile simply omits the line.
final installedVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return appBuildLabel(info.buildNumber);
  } catch (_) {
    return null;
  }
});

final appUpdateConfigProvider = Provider<AppUpdateConfig>((ref) {
  return FirebaseAppUpdateConfig();
});

final appUpdatePlatformProvider = Provider<TargetPlatform>((ref) {
  return defaultTargetPlatform;
});

typedef StoreLauncher = Future<bool> Function(Uri url);

final storeLauncherProvider = Provider<StoreLauncher>((ref) {
  return (url) => launchUrl(url, mode: LaunchMode.externalApplication);
});

class _RememberedUpdate {
  AppUpdateStatus status = const AppUpdateStatus.clear();
  var hasStatus = false;
}

final _rememberedUpdateProvider = Provider<_RememberedUpdate>((ref) {
  return _RememberedUpdate();
});

/// Whether this install is older than `min_app_version`. A failed refresh
/// keeps the last answer, so a dropped connection does not lift the block.
final appUpdateStatusProvider = FutureProvider<AppUpdateStatus>((ref) async {
  final memory = ref.watch(_rememberedUpdateProvider);
  final version = ref.watch(installedVersionProvider.future);
  final config = ref.watch(appUpdateConfigProvider);
  final platform = ref.watch(appUpdatePlatformProvider);
  try {
    final policy = await config.load();
    final status = decideAppUpdate(
      installedVersion: await version,
      minimumVersion: policy.minimumVersion,
      platform: platform,
    );
    memory.status = status;
    memory.hasStatus = true;
    return status;
  } catch (_) {
    return memory.hasStatus ? memory.status : const AppUpdateStatus.clear();
  }
});

final class FirebaseAppUpdateConfig implements AppUpdateConfig {
  @override
  Future<AppUpdatePolicy> load() async {
    if (!_firebaseReady()) return const AppUpdatePolicy.empty();
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults(const {minAppVersionKey: ''});
    await remoteConfig.fetchAndActivate();
    return AppUpdatePolicy(
      minimumVersion: remoteConfig.getString(minAppVersionKey),
    );
  }
}

bool _firebaseReady() {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Covers the app when Remote Config says this version has to update.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(appUpdateStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(appUpdateStatusProvider).value;
    final url = status != null && status.blocked ? status.storeUrl : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: url != null,
          child: ExcludeSemantics(excluding: url != null, child: widget.child),
        ),
        if (url != null)
          Positioned.fill(child: _UpdateRequiredScreen(storeUrl: url)),
      ],
    );
  }
}

class _UpdateRequiredScreen extends ConsumerStatefulWidget {
  const _UpdateRequiredScreen({required this.storeUrl});

  final Uri storeUrl;

  @override
  ConsumerState<_UpdateRequiredScreen> createState() =>
      _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends ConsumerState<_UpdateRequiredScreen> {
  var _busy = false;

  Future<void> _openStore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await ref.read(storeLauncherProvider)(widget.storeUrl);
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (opened) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.updateRequiredStoreFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      ColoredBox(
                        color: colors.station,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 16, 20),
                          child: Text(
                            l10n.updateRequiredTitle,
                            style: programTitle(
                              context,
                              colors.onStation,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.updateRequiredBody,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ScheduleAction(
                  label: l10n.updateRequiredAction,
                  onPressed: _busy ? null : _openStore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
