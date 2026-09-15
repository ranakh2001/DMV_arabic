import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/network/dio_providers.dart';
import '../../features/apple_iap/presentation/providers/apple_iap_data_providers.dart';
import '../../features/payment/data/services/in_app_purchase_payment_service.dart';
import '../../features/payment/data/services/stripe_payment_service.dart';
import '../../features/payment/domain/services/payment_service.dart';
import '../../features/payment/presentation/providers/payment_data_providers.dart';
import '../../features/subscription/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';

/// Composition root for the platform-specific payment provider.
///
/// This is the **only** place that decides between Stripe and Apple In-App
/// Purchase. Presentation code depends on [PaymentService] and never branches
/// on platform itself (App Store Guideline 3.1.1: on iOS the only purchase
/// path is Apple IAP, and Stripe must not be reachable at all).

/// `Platform.isIOS`, exposed as a provider purely so tests can exercise the
/// iOS branch of [paymentServiceProvider] on a non-iOS host. Not overridden
/// anywhere in production code.
final paymentPlatformIsIOSProvider = Provider<bool>((_) => Platform.isIOS);

/// The StoreKit entry point. Only ever read inside the iOS branch below;
/// overridable so the iOS branch can be unit-tested with a fake store.
final inAppPurchaseStoreProvider = Provider<InAppPurchase>(
  (_) => InAppPurchase.instance,
);

/// A stateless `SubscriptionRepository` for the payment services' catalogue
/// lookup. Built here (rather than watching the one in
/// `subscription_packages_providers.dart`) to keep the import graph acyclic:
/// that file depends on [paymentServiceProvider].
final _paymentCatalogueRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(
    remote: SubscriptionRemoteDataSource(ref.watch(dioProvider)),
  ),
);

/// iOS → [InAppPurchasePaymentService]. Everything else → the pre-existing
/// [StripePaymentService]. On iOS the Stripe branch is never evaluated, so
/// no Stripe class is instantiated and no Stripe SDK call is made.
final paymentServiceProvider = Provider<PaymentService>((ref) {
  if (ref.watch(paymentPlatformIsIOSProvider)) {
    final service = InAppPurchasePaymentService(
      store: ref.watch(inAppPurchaseStoreProvider),
      iapRepository: ref.watch(appleIapRepositoryProvider),
      paymentRepository: ref.watch(paymentRepositoryProvider),
      subscriptionRepository: ref.watch(_paymentCatalogueRepositoryProvider),
    );
    ref.onDispose(service.dispose);
    return service;
  }

  final service = StripePaymentService(
    paymentRepository: ref.watch(paymentRepositoryProvider),
    subscriptionRepository: ref.watch(_paymentCatalogueRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
