/// A subscription tier picked for checkout, with its display text already
/// resolved for the current locale — see `SubscriptionPlansScreen._toPlans`,
/// which builds these from the real [SubscriptionPackage] catalogue.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.periodSuffix,
    required this.price,
    required this.featureLabels,
    required this.durationDays,
    this.isBestValue = false,
  });

  final int id;
  final String title;
  final String periodSuffix;
  final double price;
  final List<String> featureLabels;
  final int durationDays;

  /// Highlights this plan as the recommended/best-value choice.
  final bool isBestValue;
}
