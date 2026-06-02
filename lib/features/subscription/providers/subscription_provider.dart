import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _premiumEntitlement = 'premium';

// ── Customer info ─────────────────────────────────────────

class SubscriptionNotifier extends AsyncNotifier<CustomerInfo?> {
  @override
  Future<CustomerInfo?> build() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info;
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
    } catch (e) {
      state = AsyncData(await Purchases.getCustomerInfo());
      return false;
    }
  }

  Future<void> identify(String uid) async {
    try {
      await Purchases.logIn(uid);
      final info = await Purchases.getCustomerInfo();
      state = AsyncData(info);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (_) {}
    state = const AsyncData(null);
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, CustomerInfo?>(
        SubscriptionNotifier.new);

// ── Derived: is the user premium? ────────────────────────

final isPremiumProvider = Provider<bool>((ref) {
  final info = ref.watch(subscriptionProvider).valueOrNull;
  return info?.entitlements.active.containsKey(_premiumEntitlement) ?? false;
});

// ── Available offerings from RevenueCat ──────────────────

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
});
