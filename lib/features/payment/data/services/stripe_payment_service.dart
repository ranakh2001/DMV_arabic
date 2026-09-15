import 'dart:io';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/localization/strings_ar.dart' show stringsAr;
import '../../../../core/payment/payment_platform_helper.dart';
import '../../../../core/utils/result.dart';
import '../../../subscription/domain/entities/subscription_package.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/services/payment_service.dart';

/// [PaymentService] backed by Stripe — **Android only**.
///
/// This is the pre-existing Stripe checkout, extracted from
/// `PaymentController` without behavioural changes: create a PaymentIntent on
/// the backend, then confirm it against our own card form or the native
/// platform-pay sheet. Activation is webhook-driven on the backend; the
/// caller polls `/subscriptions/status` after [PurchaseSucceeded].
///
/// The constructor refuses to run on iOS so a mis-wired provider fails loudly
/// in QA instead of silently exposing a non-IAP purchase path (Guideline
/// 3.1.1). The only legitimate construction site is the composition root in
/// `lib/app/di/payment_service_provider.dart`, behind `Platform.isIOS`.
class StripePaymentService implements PaymentService {
  StripePaymentService({
    required PaymentRepository paymentRepository,
    required SubscriptionRepository subscriptionRepository,
  }) : _paymentRepository = paymentRepository,
       _subscriptionRepository = subscriptionRepository {
    if (Platform.isIOS) {
      throw StateError('StripePaymentService must never be created on iOS.');
    }
  }

  static const _merchantCountryCode = 'US';
  static const _currencyCode = 'USD';

  final PaymentRepository _paymentRepository;
  final SubscriptionRepository _subscriptionRepository;

  @override
  PaymentProviderKind get provider => PaymentProviderKind.stripe;

  /// Stripe can charge for any backend package, so the catalogue passes
  /// through untouched — identical to the previous direct repository call.
  @override
  Future<Result<List<SubscriptionPackage>>> getAvailablePlans() =>
      _subscriptionRepository.getSubscriptionPackages();

  @override
  Future<PurchaseOutcome> purchaseSubscription(
    SubscriptionPlan plan, {
    required PurchaseMethod method,
  }) async {
    if (method == PurchaseMethod.appStore) {
      return const PurchaseFailed(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      );
    }

    final initiateResult = await _paymentRepository.initiateSubscription(
      packageId: plan.id,
      platform: PaymentPlatformHelper.apiPlatformValue,
    );
    final initiate = initiateResult.valueOrNull;
    if (initiate == null) {
      return PurchaseFailed(message: initiateResult.failureOrNull!.messageAr);
    }

    try {
      switch (method) {
        case PurchaseMethod.card:
          // Confirms using whatever card details are currently entered in
          // the mounted [CardFormField] — see [CustomCardForm].
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: initiate.clientSecret,
            data: const PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(),
            ),
          );
        case PurchaseMethod.platformPay:
          // Native Google Pay sheet (Android). The Apple Pay branch is kept
          // verbatim from the original controller but is unreachable: this
          // class is never constructed on iOS.
          await Stripe.instance.confirmPlatformPayPaymentIntent(
            clientSecret: initiate.clientSecret,
            confirmParams: Platform.isIOS
                ? PlatformPayConfirmParams.applePay(
                    applePay: ApplePayParams(
                      merchantCountryCode: _merchantCountryCode,
                      currencyCode: _currencyCode,
                      cartItems: [
                        ApplePayCartSummaryItem.immediate(
                          label: plan.title,
                          amount: plan.price.toStringAsFixed(2),
                        ),
                      ],
                    ),
                  )
                : PlatformPayConfirmParams.googlePay(
                    googlePay: const GooglePayParams(
                      merchantCountryCode: _merchantCountryCode,
                      currencyCode: _currencyCode,
                      testEnv: true,
                      merchantName: 'DMV Exam App',
                    ),
                  ),
          );
        case PurchaseMethod.appStore:
          // Handled above; unreachable.
          break;
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User dismissed the platform pay sheet — no charge happened.
        return const PurchaseCanceled();
      }
      return PurchaseFailed(
        message: e.error.localizedMessage ?? e.error.message,
      );
    } catch (_) {
      return const PurchaseFailed(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      );
    }

    return const PurchaseSucceeded();
  }

  /// Stripe has no store-side restore; the backend is the source of truth.
  /// Not surfaced in the Android UI today — provided for interface parity.
  @override
  Future<PurchaseOutcome> restorePurchases() async {
    final status = await _paymentRepository.getSubscriptionStatus();
    return status.fold(
      onSuccess: (s) => s.hasActiveSubscription
          ? const PurchaseSucceeded()
          : PurchaseFailed(message: stringsAr['payment.restore.none']),
      onFailure: (failure) => PurchaseFailed(message: failure.messageAr),
    );
  }

  @override
  void dispose() {}
}
