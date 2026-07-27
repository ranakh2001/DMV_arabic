import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../profile/presentation/widgets/password_rule_row.dart';
import '../../../profile/presentation/widgets/password_strength_meter.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/animated_hero_icon.dart';
import '../widgets/auth_badge_chip.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_field_decoration.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/glow_elevated_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.contact, required this.code});

  final String contact;
  final String code;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
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
      setState(() => _pwStrength = _passwordStrength(_passwordCtrl.text));
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
    await ref.read(resetPasswordControllerProvider.notifier).reset(
          contact: widget.contact,
          code: widget.code,
          newPassword: _passwordCtrl.text,
        );
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

  bool get _hasLength => _passwordCtrl.text.length >= 8;
  bool get _hasUpper => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passwordCtrl.text.contains(RegExp(r'[!@#$%^&*()\-,.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);

    ref.listen(resetPasswordControllerProvider, (_, next) {
      if (next.isSuccess) {
        ref.read(resetPasswordControllerProvider.notifier).clearState();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('change_password.success'))),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradientBackground(),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  AuthTopBar(
                    title: context.t('auth.reset.header'),
                    titleColor: context.appPrimary,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 28),
                          const Center(child: AnimatedHeroIcon(icon: Icons.lock_open_rounded)),
                          const SizedBox(height: 28),
                          AuthGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(child: AuthBadgeChip(label: context.t('auth.reset.badge'))),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.t('auth.reset.new_title'),
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
                                    context.t('auth.reset.new_subtitle'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appTextSecondary, height: 1.6),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(fontFamily: 'Almarai', color: context.appTextPrimary, fontSize: 15),
                                    decoration: authPasswordDecoration(
                                      context: context,
                                      hint: context.t('field.new_password'),
                                      obscure: _obscurePassword,
                                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: Validators.password(context),
                                  ),
                                  if (_passwordCtrl.text.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    PasswordStrengthMeter(strength: _pwStrength),
                                  ],
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    obscureText: _obscureConfirm,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    style: TextStyle(fontFamily: 'Almarai', color: context.appTextPrimary, fontSize: 15),
                                    decoration: authFieldDecoration(
                                      context: context,
                                      hint: context.t('field.confirm_password'),
                                      prefixIcon: Icon(Icons.shield_outlined, color: context.appPrimary, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                          color: context.appPrimary,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                      ),
                                    ),
                                    validator: Validators.confirmPassword(context, _passwordCtrl.text),
                                  ),
                                  if (_passwordCtrl.text.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    PasswordRuleRow(label: context.t('password.rule.length'), isValid: _hasLength),
                                    PasswordRuleRow(label: context.t('password.rule.uppercase'), isValid: _hasUpper),
                                    PasswordRuleRow(label: context.t('password.rule.digit'), isValid: _hasDigit),
                                    PasswordRuleRow(label: context.t('password.rule.special'), isValid: _hasSpecial),
                                  ],
                                  const SizedBox(height: 20),
                                  if (state.isFailure && state.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        state.error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: 'Almarai', fontSize: 12, color: context.appError),
                                      ),
                                    ),
                                  GlowElevatedButton(
                                    onPressed: _submit,
                                    icon: Icons.check_circle_outline_rounded,
                                    label: context.t('auth.reset.save'),
                                    loading: state.isSubmitting,
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
