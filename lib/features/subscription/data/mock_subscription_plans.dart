import '../domain/entities/subscription_plan.dart';

/// Static plan catalogue. Stands in for a remote billing/pricing API until
/// the backend is available.
const mockSubscriptionPlans = <SubscriptionPlan>[
  SubscriptionPlan(
    id: 'monthly',
    period: SubscriptionPeriod.monthly,
    price: 9.99,
    featureKeys: [
      'subscription.feature.unlimited_questions',
      'subscription.feature.detailed_explanations',
      'subscription.feature.real_simulation',
    ],
  ),
  SubscriptionPlan(
    id: 'yearly',
    period: SubscriptionPeriod.yearly,
    price: 59.99,
    isBestValue: true,
    featureKeys: [
      'subscription.feature.all_monthly',
      'subscription.feature.save_50',
      'subscription.feature.priority_support',
      'subscription.feature.offline_mode',
    ],
  ),
];
