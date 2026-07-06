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
}
