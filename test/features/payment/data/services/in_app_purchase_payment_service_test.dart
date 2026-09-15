import 'dart:async';

import 'package:dmv/core/errors/failure.dart';
import 'package:dmv/core/utils/result.dart';
import 'package:dmv/features/apple_iap/domain/repositories/apple_iap_repository.dart';
import 'package:dmv/features/payment/data/services/in_app_purchase_payment_service.dart';
import 'package:dmv/features/payment/domain/entities/subscription_status.dart';
import 'package:dmv/features/payment/domain/repositories/payment_repository.dart';
import 'package:dmv/features/payment/domain/services/payment_service.dart';
import 'package:dmv/features/subscription/domain/entities/subscription_package.dart';
import 'package:dmv/features/subscription/domain/entities/subscription_plan.dart';
import 'package:dmv/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class MockAppleIapRepository extends Mock implements AppleIapRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class _FakePurchaseParam extends Fake implements PurchaseParam {}

class _FakePurchaseDetails extends Fake implements PurchaseDetails {}

const monthlyId = 'com.dmv.us.monthly';
const sixMonthsId = 'com.dmv.us.sixmonths';

const monthlyPlan = SubscriptionPlan(
  id: 1,
  title: 'Monthly',
  periodSuffix: '/ 30 days',
  price: 9.99,
  featureLabels: [],
  durationDays: 30,
);

ProductDetails product(String id) => ProductDetails(
  id: id,
  title: id,
  description: id,
  price: r'$9.99',
  rawPrice: 9.99,
  currencyCode: 'USD',
);

PurchaseDetails purchase(
  PurchaseStatus status, {
  String productId = monthlyId,
  String? transactionId = 'txn-1',
  bool pendingComplete = true,
  IAPError? error,
}) =>
    PurchaseDetails(
        purchaseID: transactionId,
        productID: productId,
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local',
          serverVerificationData: 'receipt-data',
          source: 'app_store',
        ),
        transactionDate: '0',
        status: status,
      )
      ..pendingCompletePurchase = pendingComplete
      ..error = error;

void main() {
  late MockInAppPurchase store;
  late MockAppleIapRepository iapRepo;
  late MockPaymentRepository paymentRepo;
  late MockSubscriptionRepository subscriptionRepo;
  late StreamController<List<PurchaseDetails>> purchases;
  late InAppPurchasePaymentService service;

  setUpAll(() {
    registerFallbackValue(_FakePurchaseParam());
    registerFallbackValue(_FakePurchaseDetails());
  });

  setUp(() {
    store = MockInAppPurchase();
    iapRepo = MockAppleIapRepository();
    paymentRepo = MockPaymentRepository();
    subscriptionRepo = MockSubscriptionRepository();
    purchases = StreamController<List<PurchaseDetails>>.broadcast();

    when(() => store.purchaseStream).thenAnswer((_) => purchases.stream);
    when(() => store.isAvailable()).thenAnswer((_) async => true);
    when(() => store.queryProductDetails(any())).thenAnswer(
      (invocation) async {
        final ids = invocation.positionalArguments.first as Set<String>;
        return ProductDetailsResponse(
          productDetails: ids.map(product).toList(),
          notFoundIDs: const [],
        );
      },
    );
    when(
      () => store.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')),
    ).thenAnswer((_) async => true);
    when(() => store.completePurchase(any())).thenAnswer((_) async {});
    when(() => store.restorePurchases()).thenAnswer((_) async {});

    when(
      () => iapRepo.getAccountToken(),
    ).thenAnswer((_) async => const Result.success('account-token'));
    when(
      () => iapRepo.verifyPurchase(
        transactionId: any(named: 'transactionId'),
        productId: any(named: 'productId'),
        receiptData: any(named: 'receiptData'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => iapRepo.submitPurchase(
        transactionId: any(named: 'transactionId'),
        productId: any(named: 'productId'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    service = InAppPurchasePaymentService(
      store: store,
      iapRepository: iapRepo,
      paymentRepository: paymentRepo,
      subscriptionRepository: subscriptionRepo,
      restoreGracePeriod: Duration.zero,
    );
  });

  tearDown(() async {
    service.dispose();
    await purchases.close();
  });

  /// Starts a purchase and waits until the StoreKit buy call has been made,
  /// i.e. the service is now waiting on the purchase stream.
  Future<Future<PurchaseOutcome>> startPurchase() async {
    final future = service.purchaseSubscription(
      monthlyPlan,
      method: PurchaseMethod.appStore,
    );
    await untilCalled(
      () => store.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')),
    );
    return future;
  }

  group('purchaseSubscription', () {
    test('maps plan duration to the App Store product and passes the '
        'account token as applicationUserName', () async {
      final future = await startPurchase();

      final param =
          verify(
                () => store.buyNonConsumable(
                  purchaseParam: captureAny(named: 'purchaseParam'),
                ),
              ).captured.single
              as PurchaseParam;
      expect(param.productDetails.id, monthlyId);
      expect(param.applicationUserName, 'account-token');
      verify(() => store.queryProductDetails({monthlyId})).called(1);

      purchases.add([purchase(PurchaseStatus.purchased)]);
      await future;
    });

    test('purchased → verifies, records, completes, PurchaseSucceeded', () async {
      final future = await startPurchase();
      final details = purchase(PurchaseStatus.purchased);
      purchases.add([details]);

      expect(await future, isA<PurchaseSucceeded>());
      verifyInOrder([
        () => iapRepo.verifyPurchase(
          transactionId: 'txn-1',
          productId: monthlyId,
          receiptData: 'receipt-data',
        ),
        () => iapRepo.submitPurchase(
          transactionId: 'txn-1',
          productId: monthlyId,
        ),
        () => store.completePurchase(details),
      ]);
    });

    test('canceled → PurchaseCanceled, transaction completed, no backend '
        'calls', () async {
      final future = await startPurchase();
      final details = purchase(PurchaseStatus.canceled);
      purchases.add([details]);

      expect(await future, isA<PurchaseCanceled>());
      verify(() => store.completePurchase(details)).called(1);
      verifyNever(
        () => iapRepo.verifyPurchase(
          transactionId: any(named: 'transactionId'),
          productId: any(named: 'productId'),
          receiptData: any(named: 'receiptData'),
        ),
      );
    });

    test('error → PurchaseFailed carrying the StoreKit message', () async {
      final future = await startPurchase();
      purchases.add([
        purchase(
          PurchaseStatus.error,
          error: IAPError(
            source: 'app_store',
            code: 'payment_invalid',
            message: 'Payment invalid',
          ),
        ),
      ]);

      final outcome = await future;
      expect(outcome, isA<PurchaseFailed>());
      expect((outcome as PurchaseFailed).message, 'Payment invalid');
    });

    test('pending keeps the caller waiting until a terminal status', () async {
      final future = await startPurchase();
      purchases.add([purchase(PurchaseStatus.pending, pendingComplete: false)]);
      await Future<void>.delayed(Duration.zero);

      var resolved = false;
      unawaited(future.then((_) => resolved = true));
      await Future<void>.delayed(Duration.zero);
      expect(resolved, isFalse);

      purchases.add([purchase(PurchaseStatus.purchased)]);
      expect(await future, isA<PurchaseSucceeded>());
    });

    test('verify network failure → PurchaseFailed and the transaction is '
        'left unfinished for retry on next launch', () async {
      when(
        () => iapRepo.verifyPurchase(
          transactionId: any(named: 'transactionId'),
          productId: any(named: 'productId'),
          receiptData: any(named: 'receiptData'),
        ),
      ).thenAnswer((_) async => const Result.failure(NetworkFailure()));

      final future = await startPurchase();
      final details = purchase(PurchaseStatus.purchased);
      purchases.add([details]);

      expect(await future, isA<PurchaseFailed>());
      verifyNever(() => store.completePurchase(details));
      verifyNever(
        () => iapRepo.submitPurchase(
          transactionId: any(named: 'transactionId'),
          productId: any(named: 'productId'),
        ),
      );
    });

    test('backend 4xx rejection → PurchaseFailed with backend message and '
        'the transaction IS completed (no endless redelivery)', () async {
      when(
        () => iapRepo.submitPurchase(
          transactionId: any(named: 'transactionId'),
          productId: any(named: 'productId'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ApiFailure(messageAr: 'مرفوض', statusCode: 422),
        ),
      );

      final future = await startPurchase();
      final details = purchase(PurchaseStatus.purchased);
      purchases.add([details]);

      final outcome = await future;
      expect((outcome as PurchaseFailed).message, 'مرفوض');
      verify(() => store.completePurchase(details)).called(1);
    });

    test('store unavailable → PurchaseFailed before any StoreKit call', () async {
      when(() => store.isAvailable()).thenAnswer((_) async => false);

      final outcome = await service.purchaseSubscription(
        monthlyPlan,
        method: PurchaseMethod.appStore,
      );

      expect(outcome, isA<PurchaseFailed>());
      verifyNever(() => store.queryProductDetails(any()));
    });

    test('product not on the App Store → PurchaseFailed, nothing bought', () async {
      when(() => store.queryProductDetails(any())).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: const [],
          notFoundIDs: const [monthlyId],
        ),
      );

      final outcome = await service.purchaseSubscription(
        monthlyPlan,
        method: PurchaseMethod.appStore,
      );

      expect(outcome, isA<PurchaseFailed>());
      verifyNever(
        () => store.buyNonConsumable(
          purchaseParam: any(named: 'purchaseParam'),
        ),
      );
    });

    test('account-token failure → PurchaseFailed with backend message, '
        'nothing bought', () async {
      when(() => iapRepo.getAccountToken()).thenAnswer(
        (_) async => const Result.failure(ApiFailure(messageAr: 'no token')),
      );

      final outcome = await service.purchaseSubscription(
        monthlyPlan,
        method: PurchaseMethod.appStore,
      );

      expect((outcome as PurchaseFailed).message, 'no token');
      verifyNever(
        () => store.buyNonConsumable(
          purchaseParam: any(named: 'purchaseParam'),
        ),
      );
    });

    test('buy call refused by StoreKit → PurchaseFailed and no pending '
        'purchase left behind', () async {
      when(
        () => store.buyNonConsumable(
          purchaseParam: any(named: 'purchaseParam'),
        ),
      ).thenAnswer((_) async => false);

      expect(
        await service.purchaseSubscription(
          monthlyPlan,
          method: PurchaseMethod.appStore,
        ),
        isA<PurchaseFailed>(),
      );

      // A second attempt must not be blocked by a stale pending purchase.
      when(
        () => store.buyNonConsumable(
          purchaseParam: any(named: 'purchaseParam'),
        ),
      ).thenAnswer((_) async => true);
      final future = await startPurchase();
      purchases.add([purchase(PurchaseStatus.canceled)]);
      expect(await future, isA<PurchaseCanceled>());
    });

    test('a second purchase while one is in flight is refused', () async {
      final first = await startPurchase();

      final second = await service.purchaseSubscription(
        monthlyPlan,
        method: PurchaseMethod.appStore,
      );
      expect(second, isA<PurchaseFailed>());

      purchases.add([purchase(PurchaseStatus.canceled)]);
      await first;
    });

    test('Stripe-only methods are refused without touching StoreKit', () async {
      final outcome = await service.purchaseSubscription(
        monthlyPlan,
        method: PurchaseMethod.card,
      );

      expect(outcome, isA<PurchaseFailed>());
      verifyNever(() => store.isAvailable());
    });

    test('an update for a different product does not settle the pending '
        'purchase', () async {
      final future = await startPurchase();
      purchases.add([
        purchase(PurchaseStatus.canceled, productId: sixMonthsId),
      ]);
      await Future<void>.delayed(Duration.zero);

      var resolved = false;
      unawaited(future.then((_) => resolved = true));
      await Future<void>.delayed(Duration.zero);
      expect(resolved, isFalse);

      purchases.add([purchase(PurchaseStatus.purchased)]);
      expect(await future, isA<PurchaseSucceeded>());
    });
  });

  group('purchase stream (no caller waiting)', () {
    test('a purchased transaction replayed by StoreKit is verified, '
        'recorded and completed', () async {
      final details = purchase(
        PurchaseStatus.purchased,
        transactionId: 'txn-old',
      );
      purchases.add([details]);
      await untilCalled(() => store.completePurchase(details));

      verify(
        () => iapRepo.verifyPurchase(
          transactionId: 'txn-old',
          productId: monthlyId,
          receiptData: 'receipt-data',
        ),
      ).called(1);
      verify(
        () => iapRepo.submitPurchase(
          transactionId: 'txn-old',
          productId: monthlyId,
        ),
      ).called(1);
    });

    test('a stray error / canceled transaction is just completed', () async {
      final details = purchase(PurchaseStatus.error);
      purchases.add([details]);
      await untilCalled(() => store.completePurchase(details));

      verifyNever(
        () => iapRepo.verifyPurchase(
          transactionId: any(named: 'transactionId'),
          productId: any(named: 'productId'),
          receiptData: any(named: 'receiptData'),
        ),
      );
    });
  });

  group('restorePurchases', () {
    test('triggers the StoreKit restore and succeeds when the backend '
        'reports an active subscription', () async {
      when(() => paymentRepo.getSubscriptionStatus()).thenAnswer(
        (_) async => const Result.success(
          SubscriptionStatus(hasActiveSubscription: true),
        ),
      );

      expect(await service.restorePurchases(), isA<PurchaseSucceeded>());
      verify(() => store.restorePurchases()).called(1);
    });

    test('fails when the backend has no active subscription', () async {
      when(() => paymentRepo.getSubscriptionStatus()).thenAnswer(
        (_) async => const Result.success(
          SubscriptionStatus(hasActiveSubscription: false),
        ),
      );

      expect(await service.restorePurchases(), isA<PurchaseFailed>());
    });

    test('a StoreKit restore error still falls through to the backend '
        'check', () async {
      when(() => store.restorePurchases()).thenThrow(Exception('boom'));
      when(() => paymentRepo.getSubscriptionStatus()).thenAnswer(
        (_) async => const Result.success(
          SubscriptionStatus(hasActiveSubscription: true),
        ),
      );

      expect(await service.restorePurchases(), isA<PurchaseSucceeded>());
    });
  });

  group('getAvailablePlans', () {
    const packages = [
      SubscriptionPackage(
        id: 1,
        nameEn: 'Monthly',
        nameAr: 'شهري',
        durationDays: 30,
        priceUsd: 9.99,
        features: [],
      ),
      SubscriptionPackage(
        id: 2,
        nameEn: '6 months',
        nameAr: '٦ أشهر',
        durationDays: 180,
        priceUsd: 39.99,
        features: [],
      ),
    ];

    setUp(() {
      when(
        () => subscriptionRepo.getSubscriptionPackages(),
      ).thenAnswer((_) async => const Result.success(packages));
    });

    test('drops packages whose App Store product is missing', () async {
      when(() => store.queryProductDetails(any())).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: [product(monthlyId)],
          notFoundIDs: const [sixMonthsId],
        ),
      );

      final result = await service.getAvailablePlans();

      expect(result.valueOrNull!.map((p) => p.id), [1]);
      verify(
        () => store.queryProductDetails({monthlyId, sixMonthsId}),
      ).called(1);
    });

    test('returns the full catalogue when StoreKit reports no products at '
        'all (paywall is never blank)', () async {
      when(() => store.queryProductDetails(any())).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: const [],
          notFoundIDs: const [monthlyId, sixMonthsId],
        ),
      );

      final result = await service.getAvailablePlans();
      expect(result.valueOrNull!.length, 2);
    });

    test('returns the full catalogue when the store is unavailable', () async {
      when(() => store.isAvailable()).thenAnswer((_) async => false);

      final result = await service.getAvailablePlans();
      expect(result.valueOrNull!.length, 2);
      verifyNever(() => store.queryProductDetails(any()));
    });

    test('propagates a backend catalogue failure untouched', () async {
      when(
        () => subscriptionRepo.getSubscriptionPackages(),
      ).thenAnswer((_) async => const Result.failure(NetworkFailure()));

      final result = await service.getAvailablePlans();
      expect(result.isFailure, isTrue);
      verifyNever(() => store.queryProductDetails(any()));
    });
  });
}
