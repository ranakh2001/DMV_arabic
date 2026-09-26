import 'package:flutter/foundation.dart' show debugPrint;

/// Set at build time with `--dart-define=IAP_DIAGNOSTICS=true` for a build
/// the developer controls (e.g. their own TestFlight build tested with a
/// sandbox account) to append the failing stage and underlying error to the
/// on-screen purchase-failure message. Off by default, so App Store users
/// never see it — `debugPrint` alone (see [logIapStage]) is enough for that.
const bool iapDiagnosticsEnabled = bool.fromEnvironment('IAP_DIAGNOSTICS');

/// Logs which stage of the Apple In-App Purchase flow failed and why.
/// `debugPrint` is not stripped in release builds, so this is visible in the
/// device console (Xcode / Console.app) for a TestFlight build without a
/// debugger attached.
void logIapStage(String stage, {Object? error}) {
  debugPrint(
    error == null ? '[IAP] stage=$stage' : '[IAP] stage=$stage error=$error',
  );
}

/// The user-facing message for a failure at [stage]: just [message]
/// normally, or [message] with the stage/error appended when
/// [iapDiagnosticsEnabled] — for reading the real cause straight off the
/// snackbar while sandbox-testing.
String iapUserMessage(String stage, String message, {Object? error}) {
  logIapStage(stage, error: error);
  if (!iapDiagnosticsEnabled) return message;
  return '$message [iap:$stage${error != null ? ' — $error' : ''}]';
}
