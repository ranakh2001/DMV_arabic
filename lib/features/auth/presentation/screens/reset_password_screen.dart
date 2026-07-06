import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/forgot_password_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.contact,
    required this.code,
  });

  final String contact;
  final String code;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _pwStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      final s = _passwordStrength(_passwordCtrl.text);
      if (s != _pwStrength) setState(() => _pwStrength = s);
    });
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static int _passwordStrength(String pw) {
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#$%^&*()\-,.?":{}|<>]'))) score++;
    return score;
  }

  static Color _strengthColor(int s) {
    switch (s) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFF57C00);
      case 3:
        return const Color(0xFF4A9CD9);
      case 4:
        return const Color(0xFF4CAF50);
      default:
        return Colors.transparent;
    }
  }

  String _strengthLabel(BuildContext context) {
    switch (_pwStrength) {
      case 1:
        return context.t('password.strength.weak');
      case 2:
        return context.t('password.strength.fair');
      case 3:
        return context.t('password.strength.good');
      case 4:
        return context.t('password.strength.strong');
      default:
        return '';
    }
  }

  bool get _hasLength => _passwordCtrl.text.length >= 8;
  bool get _hasUpper => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordCtrl.text.contains(RegExp(r'[!@#$%^&*()\-,.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strengthColor = _strengthColor(_pwStrength);

    return Scaffold(
      body: Stack(
        children: [
          AuthFlowBackground(isDark: isDark),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  AuthTopBar(
                    title: context.t('auth.reset.header'),
                    titleColor: const Color(0xFF4A9CD9),
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 28),

                          const Center(
                            child: AnimatedHeroIcon(
                              icon: Icons.lock_open_rounded,
                              iconColor: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 28),

                          GlassCard(
                            isDark: isDark,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: BadgeChip(
                                      label: context.t('auth.reset.badge'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.t('auth.reset.new_title'),
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
                                  Text(
                                    context.t('auth.reset.new_subtitle'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(155),
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // New password field
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: authFieldDecoration(
                                      context: context,
                                      hint: context.t('field.new_password'),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: const Color(0xFF4A9CD9),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    validator: Validators.password(context),
                                  ),

                                  const SizedBox(height: 10),

                                  // Strength bar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: List.generate(4, (i) {
                                            return Expanded(
                                              child: Container(
                                                height: 4,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  color: i < _pwStrength
                                                      ? strengthColor
                                                      : Colors.white.withAlpha(
                                                          30,
                                                        ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      if (_pwStrength > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          _strengthLabel(context),
                                          style: TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: strengthColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirm password field
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    obscureText: _obscureConfirm,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: authFieldDecoration(
                                      context: context,
                                      hint: context.t('field.confirm_password'),
                                      prefixIcon: const Icon(
                                        Icons.shield_outlined,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: const Color(0xFF4A9CD9),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                                    validator: Validators.confirmPassword(
                                      context,
                                      _passwordCtrl.text,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Validation checklist
                                  _CheckItem(
                                    label: context.t('password.rule.length'),
                                    isValid: _hasLength,
                                  ),
                                  _CheckItem(
                                    label: context.t(
                                      'password.rule.uppercase',
                                    ),
                                    isValid: _hasUpper,
                                  ),
                                  _CheckItem(
                                    label: context.t('password.rule.digit'),
                                    isValid: _hasDigit,
                                  ),
                                  _CheckItem(
                                    label: context.t('password.rule.special'),
                                    isValid: _hasSpecial,
                                  ),

                                  const SizedBox(height: 24),

                                  GlowElevatedButton(
                                    onPressed: _submit,
                                    icon: Icons.check_circle_outline_rounded,
                                    label: context.t('auth.reset.save'),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ── Validation checklist item ──────────────────────────────────────────────────

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.label, required this.isValid});

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            color: isValid
                ? const Color(0xFF4A9CD9)
                : Colors.white.withAlpha(70),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                color: isValid
                    ? Colors.white.withAlpha(220)
                    : Colors.white.withAlpha(120),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
