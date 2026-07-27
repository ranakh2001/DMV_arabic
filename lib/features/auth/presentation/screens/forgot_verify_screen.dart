import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/animated_hero_icon.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/forgot_verify_card.dart';
import 'reset_password_screen.dart';

class ForgotVerifyScreen extends ConsumerStatefulWidget {
  const ForgotVerifyScreen({super.key, required this.contact});

  final String contact;

  @override
  ConsumerState<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends ConsumerState<ForgotVerifyScreen> {
  Timer? _timer;
  int _secondsLeft = 60;
  String _error = '';
  String _code = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.length < 6) {
      setState(() => _error = 'رمز التحقق يتكون من 6 أرقام.');
      return;
    }
    setState(() => _error = '');
    final result = await ref
        .read(forgotVerifyControllerProvider.notifier)
        .verify(contact: widget.contact, code: _code);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _error = result.failureOrNull!.messageAr);
      return;
    }
    ref.read(forgotVerifyControllerProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResetPasswordScreen(contact: widget.contact, code: _code),
      ),
    );
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    final result = await ref.read(forgotPasswordControllerProvider.notifier).send(contact: widget.contact);
    if (!mounted) return;
    ref.read(forgotPasswordControllerProvider.notifier).reset();
    if (result.isFailure) {
      setState(() => _error = result.failureOrNull!.messageAr);
      return;
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(forgotVerifyControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradientBackground(mirrored: true),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  AuthTopBar(
                    title: context.t('auth.forgot_verify.badge'),
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
                              icon: Icons.security_rounded,
                              badges: const [
                                HeroBadge(top: 12, left: 12, size: 32, iconSize: 15, icon: Icons.mail_outline_rounded),
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
                          ForgotVerifyCard(
                            contact: widget.contact,
                            error: _error,
                            secondsLeft: _secondsLeft,
                            onCodeChanged: (code) => setState(() {
                              _code = code;
                              _error = '';
                            }),
                            onResend: _resend,
                            submitting: verifyState.isSubmitting,
                            onSubmit: _submit,
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
