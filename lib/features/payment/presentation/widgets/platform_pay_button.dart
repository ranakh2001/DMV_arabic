import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../../app/di/payment_service_provider.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../domain/services/payment_service.dart';

/// Shows the native Google Pay button — **Android/Stripe only**. Whether to
/// render at all is decided by reading [paymentServiceProvider] (the single
/// composition-root decision between Stripe and Apple In-App Purchase, see
/// `lib/app/di/payment_service_provider.dart`), never by checking
/// `Platform.isIOS`/`Platform.isAndroid` in this widget. That is deliberate:
/// this widget used to make its own platform check, which was silently
/// reverted once already and briefly rendered Stripe's Apple Pay sheet on
/// iOS (a Guideline 3.1.1 violation) — routing through the single
/// [paymentServiceProvider] decision instead means there is now exactly one
/// place in the codebase where that call is made.
class PaymentPlatformPayButton extends ConsumerWidget {
  const PaymentPlatformPayButton({super.key, required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(
      !Platform.isIOS,
      'Stripe payment widget must never be constructed on iOS — use the '
      'Apple IAP flow instead.',
    );
    final isStripe =
        ref.watch(paymentServiceProvider).provider == PaymentProviderKind.stripe;
    if (!isStripe) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: stripe.Stripe.instance.isPlatformPaySupported(
        googlePay: const stripe.IsGooglePaySupportedParams(testEnv: true),
      ),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(bottom: context.sp(16)),
          child: SizedBox(
            height: context.sp(48),
            child: stripe.PlatformPayButton(
              onPressed: onPay,
              borderRadius: context.sp(12).round(),
            ),
          ),
        );
      },
    );
  }
}
