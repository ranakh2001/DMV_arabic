/// Everything needed to drive a Stripe `PaymentSheet` for one checkout
/// attempt, returned by `POST /subscriptions/initiate`.
class SubscriptionInitiate {
  const SubscriptionInitiate({
    required this.paymentId,
    required this.clientSecret,
    required this.customerId,
    required this.ephemeralKey,
    required this.publishableKey,
  });

  final int paymentId;
  final String clientSecret;
  final String customerId;
  final String ephemeralKey;
  final String publishableKey;
}
