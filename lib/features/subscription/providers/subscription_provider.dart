import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../auth/providers/auth_providers.dart';

const _premiumEntitlement = 'premium';

bool get _rcSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

// ── Customer info ─────────────────────────────────────────

class SubscriptionNotifier extends AsyncNotifier<CustomerInfo?> {
  @override
  Future<CustomerInfo?> build() async {
    if (!_rcSupported) return null;

    // Re-run automatically whenever the signed-in user changes.
    final uid = ref.watch(currentUidProvider);

    try {
      if (uid != null) {
        await Purchases.logIn(uid);
      } else {
        await Purchases.logOut();
      }
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  Future<bool> purchase(Package package) async {
    state = const AsyncLoading();
    try {
      final info = await Purchases.purchasePackage(package);
      state = AsyncData(info);
      return info.entitlements.active.containsKey(_premiumEntitlement);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        state = AsyncData(await Purchases.getCustomerInfo());
        return false;
      }
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = const AsyncLoading();
    try {
      final info = await Purchases.restorePurchases();
      state = AsyncData(info);
      return info.entitlements.active.containsKey(_premiumEntitlement);
    } catch (_) {
      state = AsyncData(await Purchases.getCustomerInfo());
      return false;
    }
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, CustomerInfo?>(
        SubscriptionNotifier.new);

// ── Derived: is the user premium? ────────────────────────

final isPremiumProvider = Provider<bool>((ref) {
  if (!_rcSupported) return false;
  final info = ref.watch(subscriptionProvider).valueOrNull;
  return info?.entitlements.active.containsKey(_premiumEntitlement) ?? false;
});

// ── Available offerings from RevenueCat ──────────────────

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  if (!_rcSupported) return null;
  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
});
