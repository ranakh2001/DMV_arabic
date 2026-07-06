import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/forgot_password_widgets.dart';
import 'reset_password_screen.dart';

class ForgotVerifyScreen extends StatefulWidget {
  const ForgotVerifyScreen({super.key, required this.contact});

  final String contact;

  @override
  State<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends State<ForgotVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 60;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (final f in _focusNodes) {
      f.addListener(() {
        setState(() {});
      });
    }
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (_code.length < 6) {
      setState(() => _error = 'رمز التحقق يتكون من 6 أرقام.');
      return;
    }
    setState(() => _error = '');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ResetPasswordScreen(contact: widget.contact, code: _code),
      ),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canResend = _secondsLeft == 0;

    return Scaffold(
      body: Stack(
        children: [
          AuthFlowBackground(isDark: isDark, mirrored: true),
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

                          GlassCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: BadgeChip(
                                    label: context.t(
                                      'auth.forgot_verify.badge',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.t('auth.forgot_verify.title'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(155),
                                      height: 1.6,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${context.t('auth.forgot_verify.subtitle')} ',
                                      ),
                                      TextSpan(
                                        text: widget.contact,
                                        style: const TextStyle(
                                          color: Color(0xFF4A9CD9),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // OTP boxes
                                _OtpBoxes(
                                  controllers: _controllers,
                                  focusNodes: _focusNodes,
                                  onChanged: () => setState(() => _error = ''),
                                ),

                                const SizedBox(height: 20),

                                // Error
                                if (_error.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _error,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 12,
                                        color: context.appError,
                                      ),
                                    ),
                                  ),

                                // Timer row
                                Column(
                                  children: [
                                    Text(
                                      context.t('auth.forgot_verify.no_code'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 13,
                                        color: Colors.white.withAlpha(150),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          color: Color(0xFF4A9CD9),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _formatTime(_secondsLeft),
                                          style: const TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF4A9CD9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: canResend ? _resend : null,
                                      child: Text(
                                        context.t('auth.forgot_verify.resend'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: canResend
                                              ? const Color(0xFF4A9CD9)
                                              : Colors.white.withAlpha(60),
                                          decoration: canResend
                                              ? TextDecoration.underline
                                              : null,
                                          decorationColor: const Color(
                                            0xFF4A9CD9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                GlowElevatedButton(
                                  onPressed: _submit,
                                  label: context.t('auth.forgot_verify.submit'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Spam hint info card ────────────────
                          _InfoHintCard(
                            text: context.t('auth.forgot_verify.spam_hint'),
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

// ── OTP Boxes ──────────────────────────────────────────────────────────────────

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (i) => _OtpCell(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onFilled: () {
            onChanged();
            if (i < 5) {
              focusNodes[i + 1].requestFocus();
            } else {
              focusNodes[i].unfocus();
            }
          },
          onEmpty: () {
            onChanged();
            if (i > 0) {
              controllers[i - 1].clear();
              focusNodes[i - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
    required this.onEmpty,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;
  final VoidCallback onEmpty;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontFamily: 'Almarai',
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _BackspaceOnEmptyFormatter(onEmpty),
        ],
        decoration: InputDecoration(
          counterText: '',
          hintText: '-',
          hintStyle: TextStyle(
            color: Colors.white.withAlpha(80),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: const Color(0xFF060912).withAlpha(200),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF4A9CD9).withAlpha(60),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF4A9CD9).withAlpha(60),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A9CD9), width: 1.5),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty) onFilled();
        },
      ),
    );
  }
}

class _BackspaceOnEmptyFormatter extends TextInputFormatter {
  const _BackspaceOnEmptyFormatter(this.onDelete);
  final VoidCallback onDelete;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.isEmpty && newValue.text.isEmpty) {
      onDelete();
    }
    return newValue;
  }
}

// ── Spam hint info card ────────────────────────────────────────────────────────

class _InfoHintCard extends StatelessWidget {
  const _InfoHintCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1E3A).withAlpha(150),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4A9CD9).withAlpha(40),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF4A9CD9).withAlpha(180),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12,
                    color: Colors.white.withAlpha(150),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
