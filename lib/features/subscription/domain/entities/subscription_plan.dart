/// Billing cadence for a [SubscriptionPlan].
enum SubscriptionPeriod { monthly, yearly }

/// A purchasable subscription tier. Pricing and copy are mock data until
/// the billing backend is wired up — see [MockSubscriptionPlans].
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.period,
    required this.price,
    required this.featureKeys,
    this.isBestValue = false,
  });

  final String id;
  final SubscriptionPeriod period;
  final double price;

  /// Localization keys for the bullet list shown on the plan card.
  final List<String> featureKeys;

  /// Highlights this plan as the recommended/best-value choice.
  final bool isBestValue;

  String get titleKey => switch (period) {
        SubscriptionPeriod.monthly => 'subscription.plan.monthly',
        SubscriptionPeriod.yearly => 'subscription.plan.yearly',
      };

  String get periodSuffixKey => switch (period) {
        SubscriptionPeriod.monthly => 'subscription.price.per_month',
        SubscriptionPeriod.yearly => 'subscription.price.per_year',
      };
}
