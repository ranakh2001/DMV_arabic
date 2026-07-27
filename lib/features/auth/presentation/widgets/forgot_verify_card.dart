import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_format.dart';
import 'auth_badge_chip.dart';
import 'auth_glass_card.dart';
import 'glow_elevated_button.dart';
import 'otp_code_field.dart';

/// The frosted card body of [ForgotVerifyScreen]: badge, title, contact
/// line, OTP entry, error, resend timer and submit button.
class ForgotVerifyCard extends StatelessWidget {
  const ForgotVerifyCard({
    super.key,
    required this.contact,
    required this.error,
    required this.secondsLeft,
    required this.onCodeChanged,
    required this.onResend,
    required this.submitting,
    required this.onSubmit,
  });

  final String contact;
  final String error;
  final int secondsLeft;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onResend;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0;

    return AuthGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: AuthBadgeChip(label: context.t('auth.forgot_verify.badge'))),
          const SizedBox(height: 16),
          Text(
            context.t('auth.forgot_verify.title'),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Almarai', fontSize: 26, fontWeight: FontWeight.w800, color: context.appTextPrimary, height: 1.2),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appTextSecondary, height: 1.6),
              children: [
                TextSpan(text: '${context.t('auth.forgot_verify.subtitle')} '),
                TextSpan(text: contact, style: TextStyle(color: context.appPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OtpCodeField(onChanged: onCodeChanged),
          const SizedBox(height: 20),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Almarai', fontSize: 12, color: context.appError),
              ),
            ),
          Column(
            children: [
              Text(
                context.t('auth.forgot_verify.no_code'),
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appTextSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, color: context.appPrimary, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    formatMmSs(secondsLeft),
                    style: TextStyle(fontFamily: 'Almarai', fontSize: 18, fontWeight: FontWeight.w700, color: context.appPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: canResend ? onResend : null,
                child: Text(
                  context.t('auth.forgot_verify.resend'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canResend ? context.appPrimary : context.appTextDisabled,
                    decoration: canResend ? TextDecoration.underline : null,
                    decorationColor: context.appPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GlowElevatedButton(
            onPressed: submitting ? null : onSubmit,
            label: context.t('auth.forgot_verify.submit'),
            loading: submitting,
          ),
        ],
      ),
    );
  }
}
