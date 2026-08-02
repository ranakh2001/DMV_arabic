import 'dart:io';

/// Central place for platform-driven payment decisions, so a future change
/// (e.g. what value iOS should send) only needs to happen in one spot.
class PaymentPlatformHelper {
  PaymentPlatformHelper._();

  static bool get isApplePayAvailable => Platform.isIOS;

  static bool get isGooglePayAvailable => Platform.isAndroid;

  /// Value sent as `platform` to `POST /subscriptions/initiate`.
  /// The backend currently documents only `"android"` and `"web"` — there
  /// is no confirmed value for iOS yet.
  /// TODO: confirm the correct iOS value with the backend before launch.
  /// Sending `"web"` for now since it is one of the two accepted values.
  static String get apiPlatformValue {
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
