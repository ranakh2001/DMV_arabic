import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../../core/responsive/responsive_extensions.dart';

/// Shows the native Apple Pay button on iOS or the native Google Pay button
/// on Android, but only once [stripe.Stripe.instance.isPlatformPaySupported]
/// confirms the current device actually supports it (e.g. an iOS device
/// without a card in Wallet, or an Android emulator without Play Services,
/// reports false and this renders nothing). Never shown on other platforms.
///
/// flutter_stripe only exposes the unified [stripe.PlatformPayButton] widget
/// publicly — it internally renders the native Apple Pay / Google Pay button
/// for whichever platform it's running on.
class PaymentPlatformPayButton extends StatelessWidget {
  const PaymentPlatformPayButton({super.key, required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS && !Platform.isAndroid) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: Platform.isAndroid
          ? stripe.Stripe.instance.isPlatformPaySupported(
              googlePay: const stripe.IsGooglePaySupportedParams(testEnv: true),
            )
          : stripe.Stripe.instance.isPlatformPaySupported(),
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
