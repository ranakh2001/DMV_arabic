enum PaymentStatus { idle, processing, activating, success, failure }

/// Ephemeral status of the in-flight Stripe checkout.
class PaymentState {
  const PaymentState({
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.activationPending = false,
  });

  final PaymentStatus status;

  /// Set only when [status] is [PaymentStatus.failure].
  final String? errorMessage;

  /// True when the payment succeeded but `/subscriptions/status` hadn't
  /// flipped to active yet after the polling attempts — the webhook may
  /// still be catching up, this is not an error.
  final bool activationPending;

  bool get isProcessing => status == PaymentStatus.processing;

  bool get isActivating => status == PaymentStatus.activating;

  bool get isBusy => isProcessing || isActivating;

  bool get isSuccess => status == PaymentStatus.success;

  bool get isFailure => status == PaymentStatus.failure;
}
