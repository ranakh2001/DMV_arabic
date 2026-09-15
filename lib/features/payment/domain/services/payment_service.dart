import '../../../../core/utils/result.dart';
import '../../../subscription/domain/entities/subscription_package.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';

/// Which store / payment provider a [PaymentService] implementation talks to.
enum PaymentProviderKind { stripe, appleInAppPurchase }

/// How the user wants to pay for a plan.
///
/// [card] and [platformPay] are Stripe rails (Android only). [appStore] is
/// Apple In-App Purchase (iOS only). An implementation returns
/// [PurchaseFailed] for a method it does not support rather than throwing,
/// so the UI never has to know which provider is behind the interface.
enum PurchaseMethod { card, platformPay, appStore }

/// Terminal result of one purchase (or restore) attempt.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

/// The provider confirmed the charge / transaction. Backend entitlement may
/// still be catching up — callers poll `/subscriptions/status` afterwards.
final class PurchaseSucceeded extends PurchaseOutcome {
  const PurchaseSucceeded();
}

/// The user dismissed the checkout sheet. Nothing was charged.
final class PurchaseCanceled extends PurchaseOutcome {
  const PurchaseCanceled();
}

/// The purchase did not go through. [message] is user-facing (Arabic-first,
/// matching the rest of the app) and may be null when the provider gave no
/// usable text — the screen then falls back to a generic error string.
final class PurchaseFailed extends PurchaseOutcome {
  const PurchaseFailed({this.message});

  final String? message;
}

/// Platform-specific purchase provider behind the subscription checkout.
///
/// Exactly one implementation is bound per platform at the composition root
/// (`lib/app/di/payment_service_provider.dart`):
///
/// * Android → `StripePaymentService` (existing Stripe flow, unchanged).
/// * iOS     → `InAppPurchasePaymentService` (Apple In-App Purchase via
///   StoreKit). Stripe is never constructed or called on iOS.
///
/// Presentation code depends only on this interface.
abstract interface class PaymentService {
  PaymentProviderKind get provider;

  /// The backend package catalogue, narrowed to what this provider can
  /// actually sell right now (e.g. on iOS, packages whose mapped App Store
  /// product exists).
  Future<Result<List<SubscriptionPackage>>> getAvailablePlans();

  /// Runs the full purchase for [plan] and resolves once the provider has a
  /// terminal answer. Never throws — every failure mode maps to an outcome.
  Future<PurchaseOutcome> purchaseSubscription(
    SubscriptionPlan plan, {
    required PurchaseMethod method,
  });

  /// Re-establishes entitlement for an existing purchase on this account
  /// (App Store "Restore Purchases"). Resolves [PurchaseSucceeded] when the
  /// backend reports an active subscription afterwards.
  Future<PurchaseOutcome> restorePurchases();

  /// Releases any long-lived resources (e.g. the StoreKit purchase stream).
  void dispose();
}
