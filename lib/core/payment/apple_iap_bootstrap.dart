import 'package:in_app_purchase/in_app_purchase.dart';

/// Cheap sanity check that the App Store connection is available, run once
/// at startup on iOS — mirrors the existing `Stripe.instance.applySettings()`
/// init call for the Stripe flow. `InAppPurchase.instance` itself needs no
/// explicit setup; `purchaseStream` is subscribed to lazily by
/// `AppleIapController` when the paywall is first shown.
Future<void> initializeAppleIap() async {
  await InAppPurchase.instance.isAvailable();
}
