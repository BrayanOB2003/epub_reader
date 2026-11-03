import 'dart:async';

import 'package:epub_reader/features/premium/premium_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// The RevenueCat entitlement that opens the three premium sections.
const premiumEntitlement = 'premium';

/// What a purchase or a restore ended in.
enum PremiumOutcome {
  /// The entitlement is now active.
  unlocked,

  /// The person closed the store sheet.
  cancelled,

  /// The store is waiting for an approval, such as a parent's.
  pending,

  /// A restore finished and found no purchase.
  nothingToRestore,

  /// The store or the network failed.
  failed,

  /// There is no store to talk to on this device.
  unavailable,
}

/// The store side of premium, so the app and its tests do not depend on the
/// purchases plugin.
abstract interface class PremiumGateway {
  /// Whether the entitlement is active. Emits the current value once the store
  /// answers, then every change.
  Stream<bool> get unlocked;

  /// Connects to the store. Throws when this device has no store.
  Future<void> start();

  /// The price of the one payment as the store shows it, or null.
  Future<String?> price();

  Future<PremiumOutcome> buy();

  Future<PremiumOutcome> restore();
}

class RevenueCatGateway implements PremiumGateway {
  RevenueCatGateway({
    TargetPlatform? platform,
    Future<String?> Function(TargetPlatform platform)? keyLoader,
  }) : _platform = platform ?? defaultTargetPlatform,
       _keyLoader = keyLoader ?? loadRevenueCatKey;

  final TargetPlatform _platform;
  final Future<String?> Function(TargetPlatform platform) _keyLoader;
  final _unlocked = StreamController<bool>.broadcast();
  Future<void>? _starting;
  Package? _package;

  @override
  Stream<bool> get unlocked => _unlocked.stream;

  @override
  Future<void> start() => _starting ??= _configure();

  Future<void> _configure() async {
    if (kIsWeb) throw const _NoStore();
    final key = await _keyLoader(_platform);
    if (key == null) throw const _NoStore();
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(key));
    Purchases.addCustomerInfoUpdateListener(_onInfo);
    try {
      _onInfo(await Purchases.getCustomerInfo());
    } catch (error) {
      // Offline on a first launch. The listener answers once the store does.
      debugPrint('[premium] sin respuesta de la tienda $error');
    }
  }

  void _onInfo(CustomerInfo info) {
    if (_unlocked.isClosed) return;
    _unlocked.add(info.entitlements.active.containsKey(premiumEntitlement));
  }

  @override
  Future<String?> price() async {
    final package = await _lifetime();
    return package?.storeProduct.priceString;
  }

  Future<Package?> _lifetime() async {
    final saved = _package;
    if (saved != null) return saved;
    await start();
    final offerings = await Purchases.getOfferings();
    return _package = offerings.current?.lifetime;
  }

  @override
  Future<PremiumOutcome> buy() async {
    try {
      final package = await _lifetime();
      if (package == null) return PremiumOutcome.unavailable;
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _outcome(result.customerInfo);
    } on _NoStore {
      return PremiumOutcome.unavailable;
    } on PlatformException catch (error) {
      return switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.purchaseCancelledError => PremiumOutcome.cancelled,
        PurchasesErrorCode.paymentPendingError => PremiumOutcome.pending,
        PurchasesErrorCode.productAlreadyPurchasedError =>
          await _restoreQuietly(),
        _ => PremiumOutcome.failed,
      };
    } catch (_) {
      return PremiumOutcome.failed;
    }
  }

  @override
  Future<PremiumOutcome> restore() async {
    try {
      await start();
      final info = await Purchases.restorePurchases();
      final outcome = _outcome(info);
      return outcome == PremiumOutcome.unlocked
          ? outcome
          : PremiumOutcome.nothingToRestore;
    } on _NoStore {
      return PremiumOutcome.unavailable;
    } catch (_) {
      return PremiumOutcome.failed;
    }
  }

  Future<PremiumOutcome> _restoreQuietly() async {
    final outcome = await restore();
    return outcome == PremiumOutcome.nothingToRestore
        ? PremiumOutcome.failed
        : outcome;
  }

  PremiumOutcome _outcome(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(premiumEntitlement);
    _onInfo(info);
    return active ? PremiumOutcome.unlocked : PremiumOutcome.failed;
  }
}

class _NoStore implements Exception {
  const _NoStore();
}
