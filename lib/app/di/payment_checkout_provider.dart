import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/apple_iap/presentation/screens/apple_iap_checkout_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/subscription/domain/entities/subscription_plan.dart';
import 'payment_service_provider.dart';

/// Builds the checkout screen for a chosen plan.
typedef PaymentCheckoutScreenBuilder = Widget Function(SubscriptionPlan plan);

/// Composition-root counterpart of [paymentServiceProvider] for the UI: the
/// two checkout screens are genuinely different (card form + Google Pay vs.
/// a single App Store button), so the choice is made here, keyed off the
/// same platform flag, and the paywall simply asks for "the checkout screen".
///
/// On iOS the Stripe-backed [PaymentScreen] (and with it `CardFormField`,
/// `PlatformPayButton`, `Stripe.instance`) is never built.
final paymentCheckoutScreenBuilderProvider =
    Provider<PaymentCheckoutScreenBuilder>((ref) {
      if (ref.watch(paymentPlatformIsIOSProvider)) {
        return (plan) => AppleIapCheckoutScreen(plan: plan);
      }
      return (plan) => PaymentScreen(plan: plan);
    });
