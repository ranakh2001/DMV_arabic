enum PaymentStatus { idle, processing }

/// Ephemeral status of the in-flight (mock) payment request.
class PaymentState {
  const PaymentState({this.status = PaymentStatus.idle});

  final PaymentStatus status;

  bool get isProcessing => status == PaymentStatus.processing;

  PaymentState copyWith({PaymentStatus? status}) =>
      PaymentState(status: status ?? this.status);
}
