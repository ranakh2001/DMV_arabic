import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payment/presentation/providers/payment_data_providers.dart';
import '../../domain/entities/subscription_plan.dart';
import 'subscription_state.dart';

export 'subscription_state.dart';

/// Owns the user's subscription status. Hydrated from the real
/// `GET /subscriptions/status` at session start (see [hydrate], called from
/// `AuthController`) and flipped optimistically by [activate] right after a
/// successful payment.
class SubscriptionController extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  void activate(SubscriptionPlan plan) =>
      state = state.copyWith(isSubscribed: true, activePlan: plan);

  /// Confirms the real subscription status against the backend. Called once
  /// per session start (session restore or fresh login) — [AuthGate] waits
  /// for this to finish before deciding whether to show the paywall.
  Future<void> hydrate() async {
    if (state.hydrationStatus == SubscriptionHydrationStatus.loading) return;
    state = state.copyWith(
      hydrationStatus: SubscriptionHydrationStatus.loading,
    );
    final result = await ref.read(getSubscriptionStatusUsecaseProvider).call();
    result.fold(
      onSuccess: (status) => state = state.copyWith(
        isSubscribed: status.hasActiveSubscription,
        hydrationStatus: SubscriptionHydrationStatus.loaded,
      ),
      onFailure: (_) => state = state.copyWith(
        hydrationStatus: SubscriptionHydrationStatus.failed,
      ),
    );
  }

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
    NotifierProvider<SubscriptionController, SubscriptionState>(
      SubscriptionController.new,
    );

/// Whether the user closed the paywall without subscribing, for the current
/// app session. Resets on cold start so the paywall is offered again next
/// launch while the user remains unsubscribed.
final paywallDismissedProvider = StateProvider<bool>((ref) => false);
