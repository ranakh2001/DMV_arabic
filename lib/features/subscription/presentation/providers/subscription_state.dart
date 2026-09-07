import '../../domain/entities/subscription_plan.dart';

/// Whether [SubscriptionState.isSubscribed] reflects a confirmed
/// `GET /subscriptions/status` response yet. [AuthGate] waits for
/// [loaded]/[failed] before deciding whether to show the paywall, so a
/// still-subscribed user never sees it flash on cold start.
enum SubscriptionHydrationStatus { idle, loading, loaded, failed }

/// The user's subscription status, backed by `GET /subscriptions/status`
/// (see [SubscriptionController.hydrate]) once hydrated; `isSubscribed`
/// starts false and is also flipped optimistically by [SubscriptionController.activate]
/// right after a successful payment.
class SubscriptionState {
  const SubscriptionState({
    this.isSubscribed = false,
    this.activePlan,
    this.trialQuestionsUsed = 0,
    this.trialQuestionsTotal = 10,
    this.hydrationStatus = SubscriptionHydrationStatus.idle,
  });

  final bool isSubscribed;
  final SubscriptionPlan? activePlan;
  final int trialQuestionsUsed;
  final int trialQuestionsTotal;
  final SubscriptionHydrationStatus hydrationStatus;

  int get trialQuestionsRemaining =>
      (trialQuestionsTotal - trialQuestionsUsed).clamp(0, trialQuestionsTotal);

  double get trialProgress =>
      trialQuestionsTotal == 0 ? 0 : trialQuestionsUsed / trialQuestionsTotal;

  SubscriptionState copyWith({
    bool? isSubscribed,
    SubscriptionPlan? activePlan,
    int? trialQuestionsUsed,
    SubscriptionHydrationStatus? hydrationStatus,
  }) => SubscriptionState(
    isSubscribed: isSubscribed ?? this.isSubscribed,
    activePlan: activePlan ?? this.activePlan,
    trialQuestionsUsed: trialQuestionsUsed ?? this.trialQuestionsUsed,
    trialQuestionsTotal: trialQuestionsTotal,
    hydrationStatus: hydrationStatus ?? this.hydrationStatus,
  );
}
