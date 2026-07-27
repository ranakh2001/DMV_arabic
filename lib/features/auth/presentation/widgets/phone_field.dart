import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'auth_field_decoration.dart';
import 'auth_field_label.dart';

/// Where the phone icon sits relative to the input area.
enum PhoneFieldIconStyle { prefix, suffix }

/// Shared phone-number input used by the login, register and
/// forgot-password screens, so the field styling, phone icon and
/// email-or-phone validation live in one place instead of three.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.iconStyle = PhoneFieldIconStyle.prefix,
    this.textInputAction = TextInputAction.next,
    this.textDirection,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final PhoneFieldIconStyle iconStyle;
  final TextInputAction textInputAction;
  final TextDirection? textDirection;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.phone_rounded, color: context.appPrimary, size: 20);

    final field = TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      textDirection: textDirection,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(fontFamily: 'Almarai', color: context.appTextPrimary, fontSize: 15),
      decoration: authFieldDecoration(
        context: context,
        hint: hint ?? context.t('field.phone_hint'),
        prefixIcon: iconStyle == PhoneFieldIconStyle.prefix ? icon : null,
        suffixIcon: iconStyle == PhoneFieldIconStyle.suffix ? icon : null,
      ),
      validator: Validators.emailOrPhone(context),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthFieldLabel(label!),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
