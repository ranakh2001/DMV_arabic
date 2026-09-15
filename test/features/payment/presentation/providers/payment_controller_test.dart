import 'package:dmv/app/di/payment_service_provider.dart';
import 'package:dmv/core/utils/result.dart';
import 'package:dmv/features/payment/domain/entities/subscription_status.dart';
import 'package:dmv/features/payment/domain/services/payment_service.dart';
import 'package:dmv/features/payment/domain/usecases/get_subscription_status_usecase.dart';
import 'package:dmv/features/payment/presentation/providers/payment_data_providers.dart';
import 'package:dmv/features/payment/presentation/providers/payment_provider.dart';
import 'package:dmv/features/subscription/domain/entities/subscription_package.dart';
import 'package:dmv/features/subscription/domain/entities/subscription_plan.dart';
import 'package:dmv/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSubscriptionStatusUsecase extends Mock
    implements GetSubscriptionStatusUsecase {}

/// Scripted [PaymentService]: records what the controller asked for and
/// answers with a preset outcome.
class FakePaymentService implements PaymentService {
  PurchaseOutcome purchaseOutcome = const PurchaseSucceeded();
  PurchaseOutcome restoreOutcome = const PurchaseSucceeded();
  final List<(SubscriptionPlan, PurchaseMethod)> purchaseCalls = [];
  int restoreCalls = 0;

  @override
  PaymentProviderKind get provider => PaymentProviderKind.stripe;

  @override
  Future<Result<List<SubscriptionPackage>>> getAvailablePlans() async =>
      const Result.success([]);

  @override
  Future<PurchaseOutcome> purchaseSubscription(
    SubscriptionPlan plan, {
    required PurchaseMethod method,
  }) async {
    purchaseCalls.add((plan, method));
    return purchaseOutcome;
  }

  @override
  Future<PurchaseOutcome> restorePurchases() async {
    restoreCalls++;
    return restoreOutcome;
  }

  @override
  void dispose() {}
}

const plan = SubscriptionPlan(
  id: 7,
  title: 'Monthly',
  periodSuffix: '/ 30 days',
  price: 9.99,
  featureLabels: [],
  durationDays: 30,
);

void main() {
  late FakePaymentService service;
  late MockGetSubscriptionStatusUsecase statusUsecase;
  late ProviderContainer container;
  late List<PaymentStatus> statuses;

  setUp(() {
    service = FakePaymentService();
    statusUsecase = MockGetSubscriptionStatusUsecase();
    when(() => statusUsecase.call()).thenAnswer(
      (_) async =>
          const Result.success(SubscriptionStatus(hasActiveSubscription: true)),
    );

    container = ProviderContainer(
      overrides: [
        paymentServiceProvider.overrideWithValue(service),
        getSubscriptionStatusUsecaseProvider.overrideWithValue(statusUsecase),
      ],
    );
    statuses = [];
    container.listen<PaymentState>(
      paymentControllerProvider,
      (_, next) => statuses.add(next.status),
    );
  });

  tearDown(() => container.dispose());

  PaymentController controller() =>
      container.read(paymentControllerProvider.notifier);

  group('Android / Stripe entry points (unchanged contract)', () {
    test('payWithCard → processing → activating → success and activates '
        'the subscription', () async {
      await controller().payWithCard(plan: plan);

      expect(service.purchaseCalls, [(plan, PurchaseMethod.card)]);
      expect(statuses, [
        PaymentStatus.processing,
        PaymentStatus.activating,
        PaymentStatus.success,
      ]);
      final state = container.read(paymentControllerProvider);
      expect(state.activationPending, isFalse);
      expect(container.read(subscriptionProvider).isSubscribed, isTrue);
      expect(container.read(subscriptionProvider).activePlan, plan);
    });

    test('payWithPlatformPay uses the platform-pay method', () async {
      await controller().payWithPlatformPay(plan: plan);
      expect(service.purchaseCalls, [(plan, PurchaseMethod.platformPay)]);
    });

    test('cancel → back to idle, nothing activated', () async {
      service.purchaseOutcome = const PurchaseCanceled();

      await controller().payWithCard(plan: plan);

      expect(statuses, [PaymentStatus.processing, PaymentStatus.idle]);
      expect(container.read(subscriptionProvider).isSubscribed, isFalse);
      verifyNever(() => statusUsecase.call());
    });

    test('failure → failure state carrying the provider message', () async {
      service.purchaseOutcome = const PurchaseFailed(message: 'declined');

      await controller().payWithCard(plan: plan);

      expect(statuses, [PaymentStatus.processing, PaymentStatus.failure]);
      expect(container.read(paymentControllerProvider).errorMessage, 'declined');
      verifyNever(() => statusUsecase.call());
    });

    test('success but backend not active yet → success with '
        'activationPending after 3 polls', () async {
      when(() => statusUsecase.call()).thenAnswer(
        (_) async => const Result.success(
          SubscriptionStatus(hasActiveSubscription: false),
        ),
      );

      await controller().payWithCard(plan: plan);

      verify(() => statusUsecase.call()).called(3);
      final state = container.read(paymentControllerProvider);
      expect(state.isSuccess, isTrue);
      expect(state.activationPending, isTrue);
      // Optimistic activation still happens, as before.
      expect(container.read(subscriptionProvider).isSubscribed, isTrue);
    });

    test('dismissError returns to idle', () async {
      service.purchaseOutcome = const PurchaseFailed(message: 'x');
      await controller().payWithCard(plan: plan);

      controller().dismissError();

      expect(container.read(paymentControllerProvider).status, PaymentStatus.idle);
    });
  });

  group('iOS / App Store entry points', () {
    test('purchaseViaStore uses the appStore method and follows the same '
        'activation path', () async {
      await controller().purchaseViaStore(plan: plan);

      expect(service.purchaseCalls, [(plan, PurchaseMethod.appStore)]);
      expect(statuses, [
        PaymentStatus.processing,
        PaymentStatus.activating,
        PaymentStatus.success,
      ]);
    });

    test('purchaseViaStore refuses when already subscribed, without '
        'calling the store', () async {
      container.read(subscriptionProvider.notifier).activate(plan);

      await controller().purchaseViaStore(plan: plan);

      expect(service.purchaseCalls, isEmpty);
      expect(container.read(paymentControllerProvider).isFailure, isTrue);
    });

    test('restorePurchases success → re-hydrates from backend → success', () async {
      await controller().restorePurchases();

      expect(service.restoreCalls, 1);
      expect(statuses, [
        PaymentStatus.processing,
        PaymentStatus.activating,
        PaymentStatus.success,
      ]);
      expect(container.read(subscriptionProvider).isSubscribed, isTrue);
      expect(
        container.read(paymentControllerProvider).activationPending,
        isFalse,
      );
    });

    test('restorePurchases failure → failure state with message', () async {
      service.restoreOutcome = const PurchaseFailed(message: 'nothing');

      await controller().restorePurchases();

      expect(statuses, [PaymentStatus.processing, PaymentStatus.failure]);
      expect(container.read(paymentControllerProvider).errorMessage, 'nothing');
    });
  });
}
