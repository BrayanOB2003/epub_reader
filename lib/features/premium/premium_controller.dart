import 'dart:async';

import 'package:epub_reader/features/premium/premium_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final premiumGatewayProvider = Provider<PremiumGateway>((ref) {
  return RevenueCatGateway();
});

@immutable
class PremiumState {
  const PremiumState({this.unlocked, this.price});

  /// Null until the store has answered, so a screen can tell "not yet" from
  /// "not bought".
  final bool? unlocked;

  /// The store's own price string, once the offering has loaded.
  final String? price;

  PremiumState copyWith({bool? unlocked, String? price}) {
    return PremiumState(
      unlocked: unlocked ?? this.unlocked,
      price: price ?? this.price,
    );
  }
}

final premiumProvider = NotifierProvider<PremiumController, PremiumState>(
  PremiumController.new,
);

class PremiumController extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    final gateway = ref.watch(premiumGatewayProvider);
    final changes = gateway.unlocked.listen((unlocked) {
      state = state.copyWith(unlocked: unlocked);
    });
    ref.onDispose(changes.cancel);
    unawaited(_connect(gateway));
    return const PremiumState();
  }

  Future<void> _connect(PremiumGateway gateway) async {
    try {
      await gateway.start();
    } catch (error) {
      debugPrint('[premium] sin tienda $error');
      if (ref.mounted) state = state.copyWith(unlocked: false);
      return;
    }
    try {
      final price = await gateway.price();
      if (ref.mounted && price != null) state = state.copyWith(price: price);
    } catch (error) {
      debugPrint('[premium] sin precio $error');
    }
  }

  Future<PremiumOutcome> buy() async {
    final outcome = await ref.read(premiumGatewayProvider).buy();
    _apply(outcome);
    return outcome;
  }

  Future<PremiumOutcome> restore() async {
    final outcome = await ref.read(premiumGatewayProvider).restore();
    _apply(outcome);
    return outcome;
  }

  void _apply(PremiumOutcome outcome) {
    if (!ref.mounted) return;
    if (outcome == PremiumOutcome.unlocked) {
      state = state.copyWith(unlocked: true);
    }
  }
}

/// The pages only a premium reader opens. A free reader who lands on one,
/// from an old link or a notification, goes to the offer instead.
const premiumLocations = [
  '/profile/month',
  '/profile/appearance',
  '/time/books',
];

String? premiumRedirect({required String location, required bool? unlocked}) {
  if (unlocked != false) return null;
  for (final prefix in premiumLocations) {
    if (location == prefix || location.startsWith('$prefix/')) {
      return '/profile/premium';
    }
  }
  return null;
}
