import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/localization/strings_ar.dart' show stringsAr;
import '../../../../core/payment/apple_iap_product_catalog.dart';
import '../../../payment/presentation/providers/payment_data_providers.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../state/apple_iap_state.dart';
import 'apple_iap_data_providers.dart';

export '../state/apple_iap_state.dart';

/// Drives the Apple In-App Purchase checkout (iOS only, Non-Renewing
/// Subscriptions): queries the StoreKit product, buys it, then verifies +
/// records the transaction with the backend and polls `/subscriptions/status`
/// until it confirms activation. Mirrors `PaymentController` (the Stripe
/// equivalent) as closely as StoreKit's async purchase-stream model allows.
class AppleIapController extends Notifier<AppleIapState> {
  static const _pollInterval = Duration(seconds: 1);
  static const _maxPollAttempts = 3;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  String? _pendingProductId;
  SubscriptionPlan? _pendingPlan;

  @override
  AppleIapState build() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
    );
    ref.onDispose(() => _subscription?.cancel());
    return const AppleIapState();
  }

  Future<void> buy(SubscriptionPlan plan) async {
    if (ref.read(subscriptionProvider).isSubscribed) {
      state = AppleIapState(
        status: AppleIapStatus.failure,
        errorMessage: stringsAr['iap.error.already_subscribed'],
      );
      return;
    }

    state = const AppleIapState(status: AppleIapStatus.queryingProduct);

    if (!await InAppPurchase.instance.isAvailable()) {
      state = AppleIapState(
        status: AppleIapStatus.failure,
        errorMessage: stringsAr['iap.error.unavailable'],
      );
      return;
    }

    final productId = AppleIapProductCatalog.productIdForDurationDays(
      plan.durationDays,
    );
    final response = await InAppPurchase.instance.queryProductDetails({
      productId,
    });
    if (response.productDetails.isEmpty) {
      state = AppleIapState(
        status: AppleIapStatus.failure,
        errorMessage: stringsAr['iap.error.product_not_found'],
      );
      return;
    }

    final tokenResult = await ref
        .read(getAppleAccountTokenUsecaseProvider)
        .call();
    final token = tokenResult.valueOrNull;
    if (token == null) {
      state = AppleIapState(
        status: AppleIapStatus.failure,
        errorMessage:
            tokenResult.failureOrNull?.messageAr ??
            stringsAr['iap.error.account_token_failed'],
      );
      return;
    }

    _pendingProductId = productId;
    _pendingPlan = plan;
    state = const AppleIapState(status: AppleIapStatus.purchasing);

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: response.productDetails.first,
        applicationUserName: token,
      ),
    );
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != _pendingProductId) continue;
      await _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        state = const AppleIapState(status: AppleIapStatus.purchasing);
        return;
      case PurchaseStatus.canceled:
        state = const AppleIapState();
        return;
      case PurchaseStatus.error:
        state = AppleIapState(
          status: AppleIapStatus.failure,
          errorMessage:
              purchase.error?.message ?? stringsAr['iap.error.purchase_failed'],
        );
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        return;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _verifyAndActivate(purchase);
        return;
    }
  }

  Future<void> _verifyAndActivate(PurchaseDetails purchase) async {
    final plan = _pendingPlan;
    final transactionId = purchase.purchaseID;
    if (plan == null || transactionId == null) {
      state = AppleIapState(
        status: AppleIapStatus.failure,
        errorMessage: stringsAr['iap.error.purchase_failed'],
      );
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      return;
    }

    try {
      state = const AppleIapState(status: AppleIapStatus.verifying);
      final verifyResult = await ref
          .read(verifyApplePurchaseUsecaseProvider)
          .call(
            transactionId: transactionId,
            productId: purchase.productID,
            receiptData: purchase.verificationData.serverVerificationData,
          );
      if (verifyResult.isFailure) {
        state = AppleIapState(
          status: AppleIapStatus.failure,
          errorMessage:
              verifyResult.failureOrNull?.messageAr ??
              stringsAr['iap.error.verify_failed'],
        );
        return;
      }

      final submitResult = await ref
          .read(submitAppleIapPurchaseUsecaseProvider)
          .call(transactionId: transactionId, productId: purchase.productID);
      if (submitResult.isFailure) {
        state = AppleIapState(
          status: AppleIapStatus.failure,
          errorMessage:
              submitResult.failureOrNull?.messageAr ??
              stringsAr['iap.error.purchase_failed'],
        );
        return;
      }

      state = const AppleIapState(status: AppleIapStatus.activating);
      final activated = await _pollUntilActive();
      ref.read(subscriptionProvider.notifier).activate(plan);

      state = AppleIapState(
        status: AppleIapStatus.success,
        activationPending: !activated,
      );
    } finally {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      _pendingProductId = null;
      _pendingPlan = null;
    }
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

  /// Returns to idle after the screen has surfaced the error.
  void dismissError() => state = const AppleIapState();
}

final appleIapControllerProvider =
    NotifierProvider<AppleIapController, AppleIapState>(
      AppleIapController.new,
    );
