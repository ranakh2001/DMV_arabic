import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/payment_service_provider.dart';
import '../../../../core/localization/strings_ar.dart' show stringsAr;
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/services/payment_service.dart';
import '../state/payment_state.dart';
import 'payment_data_providers.dart';

export '../state/payment_state.dart';

/// Drives the subscription checkout against whichever [PaymentService] the
/// composition root bound for this platform (Stripe on Android, Apple
/// In-App Purchase on iOS) and then polls `/subscriptions/status` until the
/// backend confirms activation.
///
/// The Stripe-specific work that used to live here (create PaymentIntent,
/// `Stripe.instance.confirmPayment` / `confirmPlatformPayPaymentIntent`,
/// `StripeException` mapping) moved verbatim into `StripePaymentService`;
/// the state transitions observed by `PaymentScreen` are unchanged.
class PaymentController extends Notifier<PaymentState> {
  static const _pollInterval = Duration(seconds: 1);
  static const _maxPollAttempts = 3;

  @override
  PaymentState build() => const PaymentState();

  /// Android / Stripe: confirms using whatever card details are currently
  /// entered in the mounted [CardFormField] — see [CustomCardForm].
  Future<void> payWithCard({required SubscriptionPlan plan}) =>
      _purchase(plan: plan, method: PurchaseMethod.card);

  /// Android / Stripe: confirms through the native Google Pay sheet — see
  /// [PaymentPlatformPayButton].
  Future<void> payWithPlatformPay({required SubscriptionPlan plan}) =>
      _purchase(plan: plan, method: PurchaseMethod.platformPay);

  /// iOS / Apple In-App Purchase: buys the App Store product mapped to
  /// [plan] — see [AppleIapCheckoutScreen].
  Future<void> purchaseViaStore({required SubscriptionPlan plan}) async {
    if (ref.read(subscriptionProvider).isSubscribed) {
      state = PaymentState(
        status: PaymentStatus.failure,
        errorMessage: stringsAr['iap.error.already_subscribed'],
      );
      return;
    }
    await _purchase(plan: plan, method: PurchaseMethod.appStore);
  }

  /// iOS: App Store "Restore Purchases". Re-hydrates the subscription from
  /// the backend once the provider reports success.
  Future<void> restorePurchases() async {
    state = const PaymentState(status: PaymentStatus.processing);

    final outcome = await ref.read(paymentServiceProvider).restorePurchases();
    switch (outcome) {
      case PurchaseCanceled():
        state = const PaymentState();
      case PurchaseFailed(:final message):
        state = PaymentState(
          status: PaymentStatus.failure,
          errorMessage: message,
        );
      case PurchaseSucceeded():
        state = const PaymentState(status: PaymentStatus.activating);
        await ref.read(subscriptionProvider.notifier).hydrate();
        state = PaymentState(
          status: PaymentStatus.success,
          activationPending: !ref.read(subscriptionProvider).isSubscribed,
        );
    }
  }

  Future<void> _purchase({
    required SubscriptionPlan plan,
    required PurchaseMethod method,
  }) async {
    state = const PaymentState(status: PaymentStatus.processing);

    final outcome = await ref
        .read(paymentServiceProvider)
        .purchaseSubscription(plan, method: method);

    switch (outcome) {
      case PurchaseCanceled():
        // User dismissed the checkout sheet — no charge happened, back to idle.
        state = const PaymentState();
      case PurchaseFailed(:final message):
        state = PaymentState(
          status: PaymentStatus.failure,
          errorMessage: message,
        );
      case PurchaseSucceeded():
        await _finishAfterConfirm(plan: plan);
    }
  }

  Future<void> _finishAfterConfirm({required SubscriptionPlan plan}) async {
    // Provider confirmed the charge — poll the backend for activation.
    state = const PaymentState(status: PaymentStatus.activating);
    final activated = await _pollUntilActive();

    ref.read(subscriptionProvider.notifier).activate(plan);

    state = PaymentState(
      status: PaymentStatus.success,
      activationPending: !activated,
    );
  }

  Future<bool> _pollUntilActive() async {
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      await Future<void>.delayed(_pollInterval);
      final status =
          (await ref.read(getSubscriptionStatusUsecaseProvider).call())
              .valueOrNull;
      if (status != null && status.hasActiveSubscription) return true;
    }
    return false;
  }

  /// Returns to [PaymentStatus.idle] after the screen has surfaced the error.
  void dismissError() => state = const PaymentState();
}

final paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentState>(PaymentController.new);
