/// Formats [seconds] as `mm:ss` (e.g. 75 -> "01:15"). Used by the OTP
/// resend/expiry timers across the auth flow.
String formatMmSs(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
