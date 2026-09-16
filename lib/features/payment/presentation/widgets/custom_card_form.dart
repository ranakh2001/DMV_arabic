import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Our own themed replacement for Stripe's `PaymentSheet` card entry.
/// Renders [CardFormField] directly against the screen background — no
/// extra Flutter `Container`/border wrapped around it — so it reads as
/// loose field rows rather than a boxed-in card. Mounted lazily by the
/// payment screen, only once the card method tile is expanded.
///
/// Note: Stripe's SDK does not expose the card number / expiry / CVC as
/// independent widgets — [CardFormField] is a single secure native view
/// that lays all of them out internally (that's intentional: it's what
/// keeps this integration PCI-compliant without us ever touching raw card
/// data). What we control from Flutter is limited to this shared style.
///
/// [CardFormField] styling is only partially supported by the native SDKs
/// — Android honors [CardFormStyle] fully, iOS only applies
/// `backgroundColor`. The native field itself always lays out its digits
/// left-to-right (standard for card numbers even in RTL apps — Stripe's
/// own SDK does not offer an RTL card entry mode).
class CustomCardForm extends StatelessWidget {
  const CustomCardForm({
    super.key,
    required this.controller,
    required this.onCardChanged,
  });

  final CardFormEditController controller;
  final ValueChanged<CardFieldInputDetails?> onCardChanged;

  @override
  Widget build(BuildContext context) {
    assert(
      !Platform.isIOS,
      'Stripe payment widget must never be constructed on iOS — use the '
      'Apple IAP flow instead.',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CardFormField(
      controller: controller,
      autofocus: true,
      enablePostalCode: false,
      onCardChanged: onCardChanged,
      style: CardFormStyle(
        backgroundColor: Colors.transparent,
        textColor: isDark ? Colors.white : Colors.black,
        placeholderColor: context.appTextDisabled,
        borderColor: Colors.transparent,
        borderWidth: 0,
        borderRadius: 0,
        cursorColor: context.appPrimary,
        fontSize: context.sp(15).round(),
      ),
    );
  }
}
