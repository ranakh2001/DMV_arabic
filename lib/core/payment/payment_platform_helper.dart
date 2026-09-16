import 'dart:io';

/// Central place for platform-driven payment decisions, so a future change
/// (e.g. what value iOS should send) only needs to happen in one spot.
///
/// This used to also expose `shouldUseAppleIap`, `isApplePayAvailable` and
/// `isGooglePayAvailable` for callers to branch on directly. That
/// responsibility has moved to `paymentServiceProvider`
/// (`lib/app/di/payment_service_provider.dart`), the single composition-root
/// decision between Stripe and Apple In-App Purchase — those getters are
/// deleted rather than left unused, so there is exactly one place left in
/// the codebase that decides platform-based payment routing.
class PaymentPlatformHelper {
  PaymentPlatformHelper._();

  /// Value sent as `platform` to `POST /subscriptions/initiate`.
  static String get apiPlatformValue {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'web';
  }
}
