import 'dart:io';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/config/stripe_config.dart';

/// One-time Stripe SDK setup, moved verbatim from `main.dart`.
///
/// Called from `main()` only when `Platform.isIOS == false`. The guard below
/// is a second line of defence: even if a future caller forgets the platform
/// check, no Stripe key is set and `Stripe.instance` is never touched on iOS
/// (App Store Guideline 3.1.1 — iOS must use Apple In-App Purchase only).
Future<void> initializeStripeSdk() async {
  if (Platform.isIOS) {
    assert(false, 'initializeStripeSdk() must never be called on iOS.');
    return;
  }

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = StripeConfig.appleMerchantIdentifier;
  await Stripe.instance.applySettings();
}
