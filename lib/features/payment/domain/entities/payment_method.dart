import 'package:flutter/material.dart';

/// Supported (mock) payment rails. No real payment SDK is wired up yet.
enum PaymentMethodType { googlePay, applePay, card }

/// Static display metadata for each [PaymentMethodType], kept out of the
/// widgets so the icon/label pairing lives in one place.
extension PaymentMethodTypeX on PaymentMethodType {
  IconData get icon => switch (this) {
    PaymentMethodType.googlePay => Icons.account_balance_wallet_rounded,
    PaymentMethodType.applePay => Icons.apple_rounded,
    PaymentMethodType.card => Icons.credit_card_rounded,
  };

  String get labelKey => switch (this) {
    PaymentMethodType.googlePay => 'payment.method.google_pay',
    PaymentMethodType.applePay => 'payment.method.apple_pay',
    PaymentMethodType.card => 'payment.method.card',
  };
}
