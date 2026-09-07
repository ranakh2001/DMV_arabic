import 'dart:io';

/// Central place for platform-driven payment decisions, so a future change
/// (e.g. what value iOS should send) only needs to happen in one spot.
class PaymentPlatformHelper {
  PaymentPlatformHelper._();

  static bool get isApplePayAvailable => Platform.isIOS;

  static bool get isGooglePayAvailable => Platform.isAndroid;

  /// iOS must check out through Apple In-App Purchase (StoreKit) instead of
  /// Stripe/Apple Pay — App Store policy for digital subscription content.
  static bool get shouldUseAppleIap => Platform.isIOS;

  /// Value sent as `platform` to `POST /subscriptions/initiate`.
  static String get apiPlatformValue {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'web';
  }
}
