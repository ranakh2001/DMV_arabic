import 'package:flutter/widgets.dart';
import '../localization/app_localizations.dart';

/// Client-side validators. Server is always authoritative; these guard UX only.
class Validators {
  Validators._();

  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$');

  /// US phone in E.164 format (+1XXXXXXXXXX) or 10-digit local.
  static final _phoneRe = RegExp(r'^(\+1)?\d{10}$');

  static final _codeRe = RegExp(r'^\d{6}$');

  static FormFieldValidator<String> email(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.email.required');
        }
        if (!_emailRe.hasMatch(v.trim())) {
          return context.t('validator.email.invalid');
        }
        return null;
      };

  /// Validates US phone (E.164 +1 or 10-digit).
  static FormFieldValidator<String> phone(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.phone.required');
        }
        final stripped = v.trim().replaceAll(RegExp(r'[\s\-()]'), '');
        if (!_phoneRe.hasMatch(stripped)) {
          return context.t('validator.phone.invalid');
        }
        return null;
      };

  /// Accepts email OR US phone.
  static FormFieldValidator<String> emailOrPhone(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.email_or_phone.required');
        }
        final trimmed = v.trim();
        if (trimmed.contains('@')) return Validators.email(context)(trimmed);
        return Validators.phone(context)(trimmed);
      };

  /// Minimum 8 characters (server does bcrypt hashing — never hash client-side).
  static FormFieldValidator<String> password(BuildContext context) => (v) {
        if (v == null || v.isEmpty) {
          return context.t('validator.password.required');
        }
        if (v.length < 8) {
          return context.t('validator.password.min_length');
        }
        return null;
      };

  /// Confirms passwords match.
  static FormFieldValidator<String> confirmPassword(
    BuildContext context,
    String passwordValue,
  ) =>
      (v) {
        if (v == null || v.isEmpty) {
          return context.t('validator.confirm_password.required');
        }
        if (v != passwordValue) {
          return context.t('validator.confirm_password.mismatch');
        }
        return null;
      };

  /// Six-digit verification code.
  static FormFieldValidator<String> verificationCode(BuildContext context) =>
      (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.code.required');
        }
        if (!_codeRe.hasMatch(v.trim())) {
          return context.t('validator.code.invalid');
        }
        return null;
      };

  /// Non-empty name.
  static FormFieldValidator<String> name(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.name.required');
        }
        return null;
      };

  /// Non-empty subject line (Contact Us form).
  static FormFieldValidator<String> subject(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.subject.required');
        }
        return null;
      };

  /// Non-empty message body (Contact Us form).
  static FormFieldValidator<String> message(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.message.required');
        }
        return null;
      };

  static final _cardNumberRe = RegExp(r'^\d{16}$');
  static final _cardExpiryRe = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
  static final _cardCvvRe = RegExp(r'^\d{3,4}$');

  /// Non-empty cardholder name.
  static FormFieldValidator<String> cardHolderName(BuildContext context) => (v) {
        if (v == null || v.trim().isEmpty) {
          return context.t('validator.card.holder_required');
        }
        return null;
      };

  /// 16-digit card number (spaces stripped before matching).
  static FormFieldValidator<String> cardNumber(BuildContext context) => (v) {
        final stripped = (v ?? '').replaceAll(' ', '');
        if (stripped.isEmpty) {
          return context.t('validator.card.number_required');
        }
        if (!_cardNumberRe.hasMatch(stripped)) {
          return context.t('validator.card.number_invalid');
        }
        return null;
      };

  /// MM/YY expiry, must not already be in the past.
  static FormFieldValidator<String> cardExpiry(BuildContext context) => (v) {
        final trimmed = (v ?? '').trim();
        if (trimmed.isEmpty) {
          return context.t('validator.card.expiry_required');
        }
        if (!_cardExpiryRe.hasMatch(trimmed)) {
          return context.t('validator.card.expiry_invalid');
        }
        final parts = trimmed.split('/');
        final month = int.parse(parts[0]);
        final year = 2000 + int.parse(parts[1]);
        final now = DateTime.now();
        final expiry = DateTime(year, month + 1);
        if (expiry.isBefore(now)) {
          return context.t('validator.card.expiry_invalid');
        }
        return null;
      };

  /// 3-4 digit CVV.
  static FormFieldValidator<String> cardCvv(BuildContext context) => (v) {
        final trimmed = (v ?? '').trim();
        if (trimmed.isEmpty) {
          return context.t('validator.card.cvv_required');
        }
        if (!_cardCvvRe.hasMatch(trimmed)) {
          return context.t('validator.card.cvv_invalid');
        }
        return null;
      };
}
