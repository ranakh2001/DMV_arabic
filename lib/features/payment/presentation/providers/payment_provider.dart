import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/payment/payment_platform_helper.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/entities/subscription_initiate.dart';
import '../state/payment_state.dart';
import 'payment_data_providers.dart';

export '../state/payment_state.dart';

/// Drives the Stripe checkout: creates a PaymentIntent on the backend, then
/// confirms it directly against our own card form or the native platform
/// pay sheet (Apple Pay / Google Pay) — no Stripe-branded `PaymentSheet` UI
/// is shown — then polls `/subscriptions/status` until the backend confirms
/// activation.
class PaymentController extends Notifier<PaymentState> {
  static const _pollInterval = Duration(seconds: 1);
  static const _maxPollAttempts = 3;
  static const _merchantCountryCode = 'US';
  static const _currencyCode = 'USD';

  @override
  PaymentState build() => const PaymentState();

  /// Confirms the PaymentIntent using whatever card details are currently
  /// entered in the mounted [CardFormField] — see [CustomCardForm].
  Future<void> payWithCard({
    required SubscriptionPlan plan,
    required bool autoRenew,
  }) async {
    final initiate = await _initiate(plan: plan);
    if (initiate == null) return;

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: initiate.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
    } on StripeException catch (e) {
      _handleStripeException(e);
      return;
    } catch (_) {
      _handleUnknownError();
      return;
    }

    await _finishAfterConfirm(plan: plan, autoRenew: autoRenew);
  }

  /// Confirms the PaymentIntent through the native Apple Pay (iOS) or
  /// Google Pay (Android) sheet — see [PaymentPlatformPayButton].
  Future<void> payWithPlatformPay({
    required SubscriptionPlan plan,
    required bool autoRenew,
  }) async {
    final initiate = await _initiate(plan: plan);
    if (initiate == null) return;

    // Apple Pay disabled — see stripe_config.dart, platform_pay_button.dart.
    // iOS has no platform-pay path anymore (the button no longer renders there).
    if (Platform.isIOS) {
      _handleUnknownError();
      return;
    }

    try {
      await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: initiate.clientSecret,
        // confirmParams: Platform.isIOS
        //     ? PlatformPayConfirmParams.applePay(
        //         applePay: ApplePayParams(
        //           merchantCountryCode: _merchantCountryCode,
        //           currencyCode: _currencyCode,
        //           cartItems: [
        //             ApplePayCartSummaryItem.immediate(
        //               label: plan.title,
        //               amount: plan.price.toStringAsFixed(2),
        //             ),
        //           ],
        //         ),
        //       )
        //     : PlatformPayConfirmParams.googlePay(
        //         googlePay: const GooglePayParams(
        //           merchantCountryCode: _merchantCountryCode,
        //           currencyCode: _currencyCode,
        //           testEnv: true,
        //           merchantName: 'DMV Exam App',
        //         ),
        //       ),
        confirmParams: PlatformPayConfirmParams.googlePay(
          googlePay: const GooglePayParams(
            merchantCountryCode: _merchantCountryCode,
            currencyCode: _currencyCode,
            testEnv: true,
            merchantName: 'DMV Exam App',
          ),
        ),
      );
    } on StripeException catch (e) {
      _handleStripeException(e);
      return;
    } catch (_) {
      _handleUnknownError();
      return;
    }

    await _finishAfterConfirm(plan: plan, autoRenew: autoRenew);
  }

  Future<SubscriptionInitiate?> _initiate({
    required SubscriptionPlan plan,
  }) async {
    state = const PaymentState(status: PaymentStatus.processing);

    final initiateResult = await ref
        .read(initiateSubscriptionUsecaseProvider)
        .call(
          packageId: plan.id,
          platform: PaymentPlatformHelper.apiPlatformValue,
        );

    final initiate = initiateResult.valueOrNull;
    if (initiate == null) {
      state = PaymentState(
        status: PaymentStatus.failure,
        errorMessage: initiateResult.failureOrNull!.messageAr,
      );
      return null;
    }
    return initiate;
  }

  Future<void> _finishAfterConfirm({
    required SubscriptionPlan plan,
    required bool autoRenew,
  }) async {
    // Stripe confirmed the charge — poll the backend for webhook-driven activation.
    state = const PaymentState(status: PaymentStatus.activating);
    final activated = await _pollUntilActive();

    ref.read(subscriptionProvider.notifier)
      ..activate(plan)
      ..setAutoRenew(autoRenew);

    state = PaymentState(
      status: PaymentStatus.success,
      activationPending: !activated,
    );
  }

  void _handleStripeException(StripeException e) {
    if (e.error.code == FailureCode.Canceled) {
      // User dismissed the platform pay sheet — no charge happened, back to idle.
      state = const PaymentState();
    } else {
      state = PaymentState(
        status: PaymentStatus.failure,
        errorMessage: e.error.localizedMessage ?? e.error.message,
      );
    }
  }

  void _handleUnknownError() {
    state = const PaymentState(
      status: PaymentStatus.failure,
      errorMessage: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
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
