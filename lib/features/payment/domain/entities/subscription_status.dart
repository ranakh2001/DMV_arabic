/// Backend-confirmed subscription status, from `GET /subscriptions/status`.
class SubscriptionStatus {
  const SubscriptionStatus({required this.hasActiveSubscription});

  final bool hasActiveSubscription;
}
