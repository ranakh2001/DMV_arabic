import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../profile/presentation/widgets/password_rule_row.dart';
import '../../../profile/presentation/widgets/password_strength_meter.dart';
import '../../../states/domain/entities/us_state.dart';
import '../../../states/presentation/widgets/state_picker_sheet.dart';
import 'auth_field_decoration.dart';
import 'auth_field_label.dart';
import 'glow_elevated_button.dart';
import 'phone_field.dart';
import 'register_state_dropdown_field.dart';
import 'register_terms_row.dart';

/// The register screen's form: name/phone/password/confirm/state fields,
/// password strength + rule checklist, terms checkbox and submit button.
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.contactCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.passwordStrength,
    required this.selectedState,
    required this.onStateSelected,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.errorMessage,
    required this.submitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final int passwordStrength;
  final UsState? selectedState;
  final ValueChanged<UsState> onStateSelected;
  final bool termsAccepted;
  final ValueChanged<bool?> onTermsChanged;
  final String? errorMessage;
  final bool submitting;
  final VoidCallback onSubmit;

  bool get _hasLength => passwordCtrl.text.length >= 8;
  bool get _hasUpper => passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => passwordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      passwordCtrl.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFieldLabel(context.t('field.name')),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameCtrl,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontFamily: 'Almarai',
              color: context.appTextPrimary,
              fontSize: 15,
            ),
            decoration: authFieldDecoration(
              context: context,
              hint: context.t('field.name_hint'),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: context.appPrimary,
                size: 20,
              ),
            ),
            validator: Validators.name(context),
          ),
          const SizedBox(height: 20),
          AuthFieldLabel(context.t('field.email')),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontFamily: 'Almarai',
              color: context.appTextPrimary,
              fontSize: 15,
            ),
            decoration: authFieldDecoration(
              context: context,
              hint: context.t('field.email_hint'),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: context.appPrimary,
                size: 20,
              ),
            ),
            validator: Validators.email(context),
          ),
          const SizedBox(height: 20),
          PhoneField(controller: contactCtrl, label: context.t('field.phone')),
          const SizedBox(height: 20),
          AuthFieldLabel(context.t('field.password')),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontFamily: 'Almarai',
              color: context.appTextPrimary,
              fontSize: 15,
            ),
            decoration: authPasswordDecoration(
              context: context,
              hint: '••••••••',
              obscure: obscurePassword,
              onToggle: onTogglePassword,
            ),
            validator: Validators.password(context),
          ),
          if (passwordCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            PasswordStrengthMeter(strength: passwordStrength),
            const SizedBox(height: 14),
            PasswordRuleRow(
              label: context.t('password.rule.length'),
              isValid: _hasLength,
            ),
            PasswordRuleRow(
              label: context.t('password.rule.uppercase'),
              isValid: _hasUpper,
            ),
            PasswordRuleRow(
              label: context.t('password.rule.digit'),
              isValid: _hasDigit,
            ),
            PasswordRuleRow(
              label: context.t('password.rule.special'),
              isValid: _hasSpecial,
            ),
          ],
          const SizedBox(height: 6),
          AuthFieldLabel(context.t('field.confirm_password')),
          const SizedBox(height: 8),
          TextFormField(
            controller: confirmCtrl,
            obscureText: obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            style: TextStyle(
              fontFamily: 'Almarai',
              color: context.appTextPrimary,
              fontSize: 15,
            ),
            decoration: authFieldDecoration(
              context: context,
              hint: context.t('field.confirm_password_hint'),
              prefixIcon: Icon(
                Icons.shield_outlined,
                color: context.appPrimary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: context.appPrimary,
                  size: 20,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            validator: Validators.confirmPassword(context, passwordCtrl.text),
          ),
          const SizedBox(height: 20),
          AuthFieldLabel(context.t('field.state')),
          const SizedBox(height: 8),
          RegisterStateDropdownField(
            selectedState: selectedState?.name(arabic: isRtl),
            onTap: () => showStatePickerSheet(
              context,
              currentStateId: selectedState?.id,
              onSelected: onStateSelected,
            ),
          ),
          const SizedBox(height: 24),
          RegisterTermsRow(accepted: termsAccepted, onChanged: onTermsChanged),
          const SizedBox(height: 24),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.appError.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.appError.withAlpha(100)),
                ),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: context.appError,
                  ),
                ),
              ),
            ),
          GlowElevatedButton(
            onPressed: submitting ? null : onSubmit,
            label: context.t('auth.register.submit'),
            loading: submitting,
          ),
        ],
      ),
    );
  }
}
