/// Stripe-related constants. Only the publishable key belongs on the
/// client — the secret key and webhook secret are backend-only and must
/// never appear here.
class StripeConfig {
  StripeConfig._();

  static const String publishableKey =
      'pk_test_51Ty2ZB2N8bP03jv5k2OoRS11akM14SUNeMRjlw7FVG9PCAwYdQUpULjNS3ZuMTO9maSRRP6R5swasywmFmxNITRt007bGnuaJw';

  /// Apple Pay merchant identifier registered in the Apple Developer
  /// account, required by `Stripe.instance.applySettings()` on iOS.
  /// Enable the Apple Pay capability for this merchant ID in Xcode
  /// (Signing & Capabilities → + Capability → Apple Pay).
  static const String appleMerchantIdentifier = 'merchant.com.dmv.arabic.us';
}
