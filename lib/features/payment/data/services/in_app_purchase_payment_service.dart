import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show PlatformException;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/localization/strings_ar.dart' show stringsAr;
import '../../../../core/localization/strings_en.dart' show stringsEn;
import '../../../../core/payment/apple_iap_product_catalog.dart';
import '../../../../core/utils/result.dart';
import '../../../apple_iap/domain/repositories/apple_iap_repository.dart';
import '../../../subscription/domain/entities/subscription_package.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/services/payment_service.dart';

/// [PaymentService] backed by Apple In-App Purchase (StoreKit via the
/// `in_app_purchase` package) — **iOS only**. Sells the two Non-Renewing
/// Subscription products `com.dmv.us.monthly` / `com.dmv.us.sixmonths`
/// (see [AppleIapProductCatalog]).
///
/// Lifecycle of one purchase:
///  1. `isAvailable()` → `queryProductDetails({productId})`.
///  2. Fetch an opaque account token from the backend; it is attached as
///     `applicationUserName` so the transaction can be tied to this user.
///  3. `buyNonConsumable(...)` — the answer arrives asynchronously on
///     [InAppPurchase.purchaseStream]; a [Completer] bridges it back into the
///     `Future<PurchaseOutcome>` returned by [purchaseSubscription].
///  4. On `purchased`/`restored`: `POST /subscriptions/verify` (receipt
///     validation) then `POST /subscriptions/apple-iap` (grants entitlement
///     the same way the Stripe webhook does), then `completePurchase()`.
///
/// The stream is subscribed for the whole lifetime of the service so
/// transactions interrupted in a previous session (app killed mid-purchase,
/// "Ask to Buy" approved later) are still verified, recorded and finished.
class InAppPurchasePaymentService implements PaymentService {
  InAppPurchasePaymentService({
    required InAppPurchase store,
    required AppleIapRepository iapRepository,
    required PaymentRepository paymentRepository,
    required SubscriptionRepository subscriptionRepository,
    Duration restoreGracePeriod = const Duration(seconds: 2),
  }) : _store = store,
       _iapRepository = iapRepository,
       _paymentRepository = paymentRepository,
       _subscriptionRepository = subscriptionRepository,
       _restoreGracePeriod = restoreGracePeriod {
    _streamSubscription = _store.purchaseStream.listen(
      _enqueuePurchaseUpdates,
      onError: (Object error) {
        // StoreKit stream errors are not tied to a specific purchase; the
        // in-flight one (if any) will surface its own error/cancel event.
        debugPrint('[IAP] purchaseStream error: $error');
      },
    );
  }

  final InAppPurchase _store;
  final AppleIapRepository _iapRepository;
  final PaymentRepository _paymentRepository;
  final SubscriptionRepository _subscriptionRepository;
  final Duration _restoreGracePeriod;

  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;

  /// Serialises stream batches so two rapid events can't interleave their
  /// backend calls / completer settlement.
  Future<void> _queue = Future<void>.value();

  _PendingPurchase? _pending;

  /// Verification work started for transactions that no caller is awaiting
  /// (interrupted purchases replayed by StoreKit, restored transactions).
  final Set<Future<void>> _unattendedWork = {};

  @override
  PaymentProviderKind get provider => PaymentProviderKind.appleInAppPurchase;

  /// Backend catalogue narrowed to packages whose mapped App Store product
  /// exists, each carrying the App Store's own title and localized price.
  ///
  /// If the store is unreachable or none of our products are found, this is a
  /// failure with a user-facing message — never the backend's USD prices,
  /// which could differ from what StoreKit would charge.
  @override
  Future<Result<List<SubscriptionPackage>>> getAvailablePlans() async {
    final result = await _subscriptionRepository.getSubscriptionPackages();
    final packages = result.valueOrNull;
    if (packages == null) return result;

    try {
      if (!await _store.isAvailable()) {
        debugPrint('[IAP] getAvailablePlans: App Store is not available');
        return _storeFailure('iap.error.unavailable');
      }
      final response = await _store.queryProductDetails(
        AppleIapProductCatalog.productIds,
      );
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
          '[IAP] getAvailablePlans: products not found in App Store Connect: '
          '${response.notFoundIDs}',
        );
      }
      if (response.error != null) {
        debugPrint(
          '[IAP] getAvailablePlans: queryProductDetails error '
          '${response.error!.code}: ${response.error!.message}',
        );
        return _storeFailure('iap.error.product_not_found');
      }

      final details = {for (final p in response.productDetails) p.id: p};
      final available = <SubscriptionPackage>[];
      for (final package in packages) {
        final productId = AppleIapProductCatalog.productIdForDurationDays(
          package.durationDays,
        );
        if (productId == null) {
          debugPrint(
            '[IAP] getAvailablePlans: package ${package.id} has '
            '${package.durationDays} days, which maps to no App Store product; '
            'not offered on iOS',
          );
          continue;
        }
        final product = details[productId];
        if (product == null) continue;
        available.add(
          package.withStoreDetails(title: product.title, price: product.price),
        );
      }
      if (available.isEmpty) {
        debugPrint('[IAP] getAvailablePlans: no purchasable packages');
        return _storeFailure('iap.error.product_not_found');
      }
      return Result.success(available);
    } catch (e, st) {
      debugPrint('[IAP] getAvailablePlans failed: $e\n$st');
      return _storeFailure('iap.error.unavailable');
    }
  }

  Result<List<SubscriptionPackage>> _storeFailure(String key) => Result.failure(
    UnavailableFailure(messageAr: stringsAr[key]!, messageEn: stringsEn[key]),
  );

  @override
  Future<PurchaseOutcome> purchaseSubscription(
    SubscriptionPlan plan, {
    required PurchaseMethod method,
  }) async {
    if (method != PurchaseMethod.appStore) {
      debugPrint('[IAP] purchase refused: unsupported method $method on iOS');
      return PurchaseFailed(message: stringsAr['iap.error.purchase_failed']);
    }
    if (_pending != null) {
      return PurchaseFailed(
        message: stringsAr['iap.error.purchase_in_progress'],
      );
    }
    if (!await _store.isAvailable()) {
      debugPrint('[IAP] purchase: App Store is not available');
      return PurchaseFailed(message: stringsAr['iap.error.unavailable']);
    }

    final productId = AppleIapProductCatalog.productIdForDurationDays(
      plan.durationDays,
    );
    if (productId == null) {
      debugPrint(
        '[IAP] purchase: plan ${plan.id} has ${plan.durationDays} days, '
        'which maps to no App Store product',
      );
      return PurchaseFailed(message: stringsAr['iap.error.product_not_found']);
    }
    final ProductDetailsResponse response;
    try {
      response = await _store.queryProductDetails({productId});
    } catch (e, st) {
      debugPrint('[IAP] purchase: queryProductDetails threw: $e\n$st');
      return PurchaseFailed(message: stringsAr['iap.error.product_not_found']);
    }
    if (response.error != null || response.productDetails.isEmpty) {
      debugPrint(
        '[IAP] purchase: product $productId unavailable. '
        'notFoundIDs=${response.notFoundIDs} '
        'error=${response.error?.code}: ${response.error?.message}',
      );
      return PurchaseFailed(message: stringsAr['iap.error.product_not_found']);
    }

    final tokenResult = await _iapRepository.getAccountToken();
    final token = tokenResult.valueOrNull;
    if (token == null) {
      debugPrint(
        '[IAP] purchase: account token failed: ${tokenResult.failureOrNull}',
      );
      return PurchaseFailed(
        message:
            tokenResult.failureOrNull?.messageAr ??
            stringsAr['iap.error.account_token_failed'],
      );
    }

    final pending = _PendingPurchase(productId: productId);
    _pending = pending;
    try {
      // Non-Renewing Subscriptions go through the non-consumable API; on iOS
      // the distinction only affects Android's auto-consume behaviour.
      final launched = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: response.productDetails.first,
          applicationUserName: token,
        ),
      );
      if (!launched) {
        debugPrint('[IAP] purchase: buyNonConsumable returned false');
        _pending = null;
        return PurchaseFailed(message: stringsAr['iap.error.purchase_failed']);
      }
    } on PlatformException catch (e) {
      debugPrint('[IAP] purchase: PlatformException ${e.code}: ${e.message}');
      _pending = null;
      return PurchaseFailed(
        message: e.message ?? stringsAr['iap.error.purchase_failed'],
      );
    } catch (e, st) {
      debugPrint('[IAP] purchase: buyNonConsumable threw: $e\n$st');
      _pending = null;
      return PurchaseFailed(message: stringsAr['iap.error.purchase_failed']);
    }

    return pending.completer.future;
  }

  /// StoreKit's `restoreCompletedTransactions` only replays non-consumables
  /// and auto-renewables; our Non-Renewing Subscriptions are tied to the
  /// user's account on the backend, which therefore stays the source of
  /// truth. We still trigger the StoreKit restore (any replayed transaction
  /// is verified + recorded by the stream handler), wait briefly for it to
  /// land, then ask the backend whether the account is active.
  @override
  Future<PurchaseOutcome> restorePurchases() async {
    if (!await _store.isAvailable()) {
      debugPrint('[IAP] restore: App Store is not available');
      return PurchaseFailed(message: stringsAr['iap.error.unavailable']);
    }
    try {
      await _store.restorePurchases();
    } catch (e, st) {
      // Fall through — the backend check below still answers the question.
      debugPrint('[IAP] restore: restorePurchases threw: $e\n$st');
    }
    await Future<void>.delayed(_restoreGracePeriod);
    await Future.wait(_unattendedWork.toList());

    final status = await _paymentRepository.getSubscriptionStatus();
    return status.fold(
      onSuccess: (s) => s.hasActiveSubscription
          ? const PurchaseSucceeded()
          : PurchaseFailed(message: stringsAr['payment.restore.none']),
      onFailure: (failure) => PurchaseFailed(message: failure.messageAr),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.completer.isCompleted) {
      pending.completer.complete(
        PurchaseFailed(message: stringsAr['iap.error.purchase_failed']),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // purchaseStream handling
  // ---------------------------------------------------------------------------

  void _enqueuePurchaseUpdates(List<PurchaseDetails> purchases) {
    _queue = _queue.then((_) => _onPurchaseUpdates(purchases));
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final pending = _pending;
      if (pending != null && purchase.productID == pending.productId) {
        await _handlePendingPurchase(pending, purchase);
      } else {
        await _handleUnattendedPurchase(purchase);
      }
    }
  }

  Future<void> _handlePendingPurchase(
    _PendingPurchase pending,
    PurchaseDetails purchase,
  ) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Awaiting approval (e.g. Ask to Buy) — keep the caller waiting.
        return;
      case PurchaseStatus.canceled:
        await _finish(purchase);
        _settle(pending, const PurchaseCanceled());
      case PurchaseStatus.error:
        debugPrint(
          '[IAP] purchase error for ${purchase.productID}: '
          '${purchase.error?.code}: ${purchase.error?.message} '
          '(${purchase.error?.details})',
        );
        await _finish(purchase);
        _settle(
          pending,
          PurchaseFailed(
            message:
                purchase.error?.message ??
                stringsAr['iap.error.purchase_failed'],
          ),
        );
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final outcome = await _verifyAndRecord(purchase);
        _settle(pending, outcome);
    }
  }

  /// A transaction nobody is awaiting: replayed by StoreKit on launch after
  /// an interrupted purchase, or delivered by `restorePurchases()`.
  Future<void> _handleUnattendedPurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return;
      case PurchaseStatus.canceled:
      case PurchaseStatus.error:
        await _finish(purchase);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final work = _verifyAndRecord(purchase).then((_) {});
        _unattendedWork.add(work);
        try {
          await work;
        } finally {
          _unattendedWork.remove(work);
        }
    }
  }

  void _settle(_PendingPurchase pending, PurchaseOutcome outcome) {
    if (identical(_pending, pending)) _pending = null;
    if (!pending.completer.isCompleted) pending.completer.complete(outcome);
  }

  /// Verifies the receipt with the backend, records the purchase (this is
  /// what grants entitlement), and finishes the StoreKit transaction.
  ///
  /// Finishing is deliberate: a transaction is only completed once the
  /// backend has accepted it, or has *definitively* rejected it (4xx). On a
  /// network error / 5xx it is left in the queue so StoreKit redelivers it on
  /// the next launch and [_handleUnattendedPurchase] retries the recording —
  /// the user paid Apple, so we must not drop it.
  Future<PurchaseOutcome> _verifyAndRecord(PurchaseDetails purchase) async {
    final transactionId = purchase.purchaseID;
    if (transactionId == null || transactionId.isEmpty) {
      debugPrint(
        '[IAP] ${purchase.productID}: transaction has no purchaseID',
      );
      await _finish(purchase);
      return PurchaseFailed(message: stringsAr['iap.error.purchase_failed']);
    }

    final verifyResult = await _iapRepository.verifyPurchase(
      transactionId: transactionId,
      productId: purchase.productID,
      receiptData: purchase.verificationData.serverVerificationData,
    );
    if (verifyResult.isFailure) {
      debugPrint(
        '[IAP] verify failed for $transactionId: ${verifyResult.failureOrNull}',
      );
      await _finishIfRejected(purchase, verifyResult.failureOrNull);
      return PurchaseFailed(
        message:
            verifyResult.failureOrNull?.messageAr ??
            stringsAr['iap.error.verify_failed'],
      );
    }

    final submitResult = await _iapRepository.submitPurchase(
      transactionId: transactionId,
      productId: purchase.productID,
    );
    if (submitResult.isFailure) {
      debugPrint(
        '[IAP] recording failed for $transactionId: ${submitResult.failureOrNull}',
      );
      await _finishIfRejected(purchase, submitResult.failureOrNull);
      return PurchaseFailed(
        message:
            submitResult.failureOrNull?.messageAr ??
            stringsAr['iap.error.purchase_failed'],
      );
    }

    await _finish(purchase);
    return const PurchaseSucceeded();
  }

  Future<void> _finishIfRejected(
    PurchaseDetails purchase,
    Failure? failure,
  ) async {
    final status = failure is ApiFailure ? failure.statusCode : null;
    if (status != null && status >= 400 && status < 500) {
      await _finish(purchase);
    }
  }

  Future<void> _finish(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _store.completePurchase(purchase);
    } catch (e, st) {
      // Nothing actionable; StoreKit will redeliver an unfinished transaction.
      debugPrint('[IAP] completePurchase threw: $e\n$st');
    }
  }
}

class _PendingPurchase {
  _PendingPurchase({required this.productId});

  final String productId;
  final Completer<PurchaseOutcome> completer = Completer<PurchaseOutcome>();
}
