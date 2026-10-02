/// Stripe-related constants. Only the publishable key belongs on the
/// client — the secret key and webhook secret are backend-only and must
/// never appear here.
class StripeConfig {
  StripeConfig._();

  static const String publishableKey =
      'pk_live_51Ty2ZB2N8bP03jv5QlCEqIpjhI1kxhL7rkME9oXmk5V5xZfI6NzjSz4fJVLdH3MP5bjVZDI79wYGNYjaubkUMcxD00j4G1LqE0';

  /// Apple Pay merchant identifier registered in the Apple Developer
  /// account, required by `Stripe.instance.applySettings()` on iOS.
  /// Enable the Apple Pay capability for this merchant ID in Xcode
  /// (Signing & Capabilities → + Capability → Apple Pay).
  static const String appleMerchantIdentifier = 'merchant.com.dmv.arabic.us';
}
