import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import 'subscription_state.dart';

export 'subscription_state.dart';

/// Owns the (mock) subscription status. Activated by the payment flow once
/// a plan is purchased — see `PaymentController.pay`.
class SubscriptionController extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  void setAutoRenew(bool value) => state = state.copyWith(autoRenew: value);

  void activate(SubscriptionPlan plan) =>
      state = state.copyWith(isSubscribed: true, activePlan: plan);

  /// Records how many free questions the user has viewed so far this run.
  /// No-op once subscribed, and never moves the count backwards.
  void recordTrialProgress(int questionsViewed) {
    if (state.isSubscribed) return;
    final used = questionsViewed.clamp(0, state.trialQuestionsTotal);
    if (used > state.trialQuestionsUsed) {
      state = state.copyWith(trialQuestionsUsed: used);
    }
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(SubscriptionController.new);

/// Whether the user closed the paywall without subscribing, for the current
/// app session. Resets on cold start so the paywall is offered again next
/// launch while the user remains unsubscribed.
final paywallDismissedProvider = StateProvider<bool>((ref) => false);
