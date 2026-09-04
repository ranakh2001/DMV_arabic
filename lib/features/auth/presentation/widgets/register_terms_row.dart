import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../legal/presentation/screens/privacy_policy_screen.dart';
import '../../../legal/presentation/screens/terms_of_use_screen.dart';

/// The "I agree to the Terms & Privacy Policy" checkbox row on the register
/// screen, with tappable links to each document.
class RegisterTermsRow extends StatelessWidget {
  const RegisterTermsRow({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    final textStyle = TextStyle(
      fontFamily: 'Almarai',
      fontSize: 13,
      color: context.appTextSecondary,
      height: 1.6,
    );
    final linkStyle = TextStyle(
      fontFamily: 'Almarai',
      fontSize: 13,
      color: accent,
      fontWeight: FontWeight.w700,
      height: 1.6,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: onChanged,
            activeColor: accent,
            checkColor: Colors.white,
            side: BorderSide(color: accent.withAlpha(150), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text(context.t('auth.register.agree_terms'), style: textStyle),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsOfUseScreen(),
                  ),
                ),
                child: Text(
                  context.t('auth.register.terms_use'),
                  style: linkStyle,
                ),
              ),
              Text(context.t('auth.register.and_privacy'), style: textStyle),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                child: Text(
                  context.t('auth.register.privacy_policy'),
                  style: linkStyle,
                ),
              ),
              Text(context.t('auth.register.terms_suffix'), style: textStyle),
            ],
          ),
        ),
      ],
    );
  }
}
