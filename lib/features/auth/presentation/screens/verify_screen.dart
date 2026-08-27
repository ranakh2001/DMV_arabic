import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_format.dart';
import '../providers/verify_controller_provider.dart';
import '../widgets/animated_hero_icon.dart';
import '../widgets/auth_badge_chip.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/glow_elevated_button.dart';
import '../widgets/otp_code_field.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.contact});

  final String contact;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  String _code = '';
  String _localError = '';

  Future<void> _submit() async {
    if (_code.length < 6) {
      setState(() => _localError = 'رمز التحقق يتكون من 6 أرقام.');
      return;
    }
    setState(() => _localError = '');
    await ref
        .read(verifyControllerProvider.notifier)
        .verify(contact: widget.contact, code: _code);
  }

  Future<void> _resend() async {
    await ref
        .read(verifyControllerProvider.notifier)
        .resend(contact: widget.contact);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyControllerProvider);
    final error = _localError.isNotEmpty ? _localError : state.error;

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradientBackground(),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  AuthTopBar(
                    title: context.t('auth.verify.title'),
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 28),
                          Center(
                            child: AnimatedHeroIcon(
                              icon: Icons.verified_user_rounded,
                              badges: const [
                                HeroBadge(
                                  top: 12,
                                  left: 12,
                                  size: 32,
                                  iconSize: 15,
                                  icon: Icons.mail_outline_rounded,
                                ),
                                HeroBadge(
                                  bottom: 12,
                                  right: 12,
                                  size: 32,
                                  iconSize: 16,
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          AuthGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: AuthBadgeChip(
                                    label: context.t('auth.verify.title'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.t('auth.verify.title'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: context.appTextPrimary,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.t('auth.verify.subtitle'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 13,
                                    color: context.appTextSecondary,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                OtpCodeField(
                                  enabled: !state.isExpired,
                                  onChanged: (code) => setState(() {
                                    _code = code;
                                    _localError = '';
                                  }),
                                ),
                                const SizedBox(height: 20),
                                if (error != null && error.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 12,
                                        color: context.appError,
                                      ),
                                    ),
                                  ),
                                _ExpiryRow(
                                  isExpired: state.isExpired,
                                  secondsRemaining: state.secondsRemaining,
                                ),
                                const SizedBox(height: 20),
                                GlowElevatedButton(
                                  onPressed:
                                      (state.isSubmitting || state.isExpired)
                                      ? null
                                      : _submit,
                                  label: context.t('auth.verify.submit'),
                                  loading: state.isSubmitting,
                                ),
                                const SizedBox(height: 16),
                                _ResendSection(
                                  canResend: state.canResend,
                                  isResending: state.isResending,
                                  resendCooldown: state.resendCooldown,
                                  resendError: state.resendError,
                                  onResend: _resend,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  const _ExpiryRow({required this.isExpired, required this.secondsRemaining});

  final bool isExpired;
  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final color = isExpired ? context.appError : context.appPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          isExpired
              ? context.t('auth.verify.expired')
              : '${context.t('auth.verify.expires_in')} ${formatMmSs(secondsRemaining)}',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ResendSection extends StatelessWidget {
  const _ResendSection({
    required this.canResend,
    required this.isResending,
    required this.resendCooldown,
    required this.resendError,
    required this.onResend,
  });

  final bool canResend;
  final bool isResending;
  final int resendCooldown;
  final String? resendError;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (resendError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              resendError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                color: context.appError,
              ),
            ),
          ),
        GestureDetector(
          onTap: canResend ? onResend : null,
          child: isResending
              ? SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appPrimary,
                  ),
                )
              : Text(
                  canResend
                      ? context.t('auth.verify.resend')
                      : '${context.t('auth.verify.resend_in')} ${formatMmSs(resendCooldown)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canResend
                        ? context.appPrimary
                        : context.appTextDisabled,
                    decoration: canResend ? TextDecoration.underline : null,
                    decorationColor: context.appPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
