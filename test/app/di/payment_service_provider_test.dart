import 'dart:async';

import 'package:dmv/app/di/payment_checkout_provider.dart';
import 'package:dmv/app/di/payment_service_provider.dart';
import 'package:dmv/features/apple_iap/presentation/screens/apple_iap_checkout_screen.dart';
import 'package:dmv/features/payment/data/services/in_app_purchase_payment_service.dart';
import 'package:dmv/features/payment/data/services/stripe_payment_service.dart';
import 'package:dmv/features/payment/domain/services/payment_service.dart';
import 'package:dmv/features/payment/presentation/screens/payment_screen.dart';
import 'package:dmv/features/subscription/domain/entities/subscription_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

const plan = SubscriptionPlan(
  id: 1,
  title: 'Monthly',
  periodSuffix: '/ 30 days',
  price: 9.99,
  featureLabels: [],
  durationDays: 30,
);

/// The composition root is the single place that picks the payment
/// provider. These tests pin the contract: iOS → Apple In-App Purchase,
/// everything else → Stripe, for both the service and the checkout screen.
void main() {
  late MockInAppPurchase store;
  late StreamController<List<PurchaseDetails>> purchases;

  setUp(() {
    store = MockInAppPurchase();
    purchases = StreamController<List<PurchaseDetails>>.broadcast();
    when(() => store.purchaseStream).thenAnswer((_) => purchases.stream);
  });

  tearDown(() => purchases.close());

  ProviderContainer containerFor({required bool isIOS}) => ProviderContainer(
    overrides: [
      paymentPlatformIsIOSProvider.overrideWithValue(isIOS),
      inAppPurchaseStoreProvider.overrideWithValue(store),
    ],
  );

  test('iOS binds InAppPurchasePaymentService and the App Store checkout '
      'screen — never Stripe', () {
    final container = containerFor(isIOS: true);
    addTearDown(container.dispose);

    final service = container.read(paymentServiceProvider);
    expect(service, isA<InAppPurchasePaymentService>());
    expect(service.provider, PaymentProviderKind.appleInAppPurchase);
    // The StoreKit purchase stream is subscribed as soon as the service exists.
    verify(() => store.purchaseStream).called(1);

    final screen = container.read(paymentCheckoutScreenBuilderProvider)(plan);
    expect(screen, isA<AppleIapCheckoutScreen>());
  });

  test('non-iOS binds StripePaymentService and the Stripe checkout screen', () {
    final container = containerFor(isIOS: false);
    addTearDown(container.dispose);

    final service = container.read(paymentServiceProvider);
    expect(service, isA<StripePaymentService>());
    expect(service.provider, PaymentProviderKind.stripe);
    // StoreKit is never touched on the Stripe branch.
    verifyNever(() => store.purchaseStream);

    final screen = container.read(paymentCheckoutScreenBuilderProvider)(plan);
    expect(screen, isA<PaymentScreen>());
  });
}
