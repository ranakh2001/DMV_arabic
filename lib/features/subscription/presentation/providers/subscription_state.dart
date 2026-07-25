import '../../domain/entities/subscription_plan.dart';

/// Local, mock representation of the user's subscription — no backend yet.
class SubscriptionState {
  const SubscriptionState({
    this.isSubscribed = false,
    this.activePlan,
    this.autoRenew = true,
    this.trialQuestionsUsed = 7,
    this.trialQuestionsTotal = 10,
  });

  final bool isSubscribed;
  final SubscriptionPlan? activePlan;
  final bool autoRenew;
  final int trialQuestionsUsed;
  final int trialQuestionsTotal;

  int get trialQuestionsRemaining =>
      (trialQuestionsTotal - trialQuestionsUsed).clamp(0, trialQuestionsTotal);

  double get trialProgress =>
      trialQuestionsTotal == 0 ? 0 : trialQuestionsUsed / trialQuestionsTotal;

  SubscriptionState copyWith({
    bool? isSubscribed,
    SubscriptionPlan? activePlan,
    bool? autoRenew,
    int? trialQuestionsUsed,
  }) =>
      SubscriptionState(
        isSubscribed: isSubscribed ?? this.isSubscribed,
        activePlan: activePlan ?? this.activePlan,
        autoRenew: autoRenew ?? this.autoRenew,
        trialQuestionsUsed: trialQuestionsUsed ?? this.trialQuestionsUsed,
        trialQuestionsTotal: trialQuestionsTotal,
      );
}
