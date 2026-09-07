enum AppleIapStatus {
  idle,
  queryingProduct,
  purchasing,
  verifying,
  activating,
  success,
  failure,
}

/// Ephemeral status of the in-flight Apple In-App Purchase checkout.
/// Mirrors `PaymentState` (the Stripe equivalent).
class AppleIapState {
  const AppleIapState({
    this.status = AppleIapStatus.idle,
    this.errorMessage,
    this.activationPending = false,
  });

  final AppleIapStatus status;

  /// Set only when [status] is [AppleIapStatus.failure].
  final String? errorMessage;

  /// True when the purchase was recorded but `/subscriptions/status` hadn't
  /// flipped to active yet after the polling attempts.
  final bool activationPending;

  bool get isBusy =>
      status == AppleIapStatus.queryingProduct ||
      status == AppleIapStatus.purchasing ||
      status == AppleIapStatus.verifying ||
      status == AppleIapStatus.activating;

  bool get isSuccess => status == AppleIapStatus.success;

  bool get isFailure => status == AppleIapStatus.failure;
}
