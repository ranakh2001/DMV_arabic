import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../providers/profile_providers.dart';
import '../widgets/password_rule_row.dart';
import '../widgets/password_strength_meter.dart';

/// "تغيير كلمة المرور" — reached from the Profile tab. Calls
/// `PUT /users/change-password`; the server verifies the current password.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(_onNewPasswordChanged);
  }

  @override
  void dispose() {
    _newCtrl.removeListener(_onNewPasswordChanged);
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onNewPasswordChanged() {
    final strength = _passwordStrength(_newCtrl.text);
    setState(() => _strength = strength);
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

  bool get _hasLength => _newCtrl.text.length >= 8;
  bool get _hasUpper => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _newCtrl.text.contains(RegExp(r'[!@#$%^&*()\-,.?":{}|<>]'));

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(changePasswordControllerProvider.notifier)
        .submit(currentPassword: _currentCtrl.text, newPassword: _newCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordControllerProvider);

    ref.listen(changePasswordControllerProvider, (_, next) {
      if (next.isSuccess) {
        _currentCtrl.clear();
        _newCtrl.clear();
        _confirmCtrl.clear();
        setState(() => _strength = 0);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const HomeBackground(),
          SafeArea(
            child: Column(
              children: [
                AppScreenHeader(title: context.t('profile.change_password')),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.isDesktop || context.isTablet
                            ? 520
                            : double.infinity,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.sp(20),
                          context.sp(8),
                          context.sp(20),
                          context.sp(24),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassContainer(
                                radius: 20,
                                padding: EdgeInsets.symmetric(
                                  vertical: context.sp(24),
                                  horizontal: context.sp(20),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: context.sp(64),
                                      height: context.sp(64),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.appPrimary.withAlpha(30),
                                      ),
                                      child: Icon(
                                        Icons.lock_reset_rounded,
                                        color: context.appPrimary,
                                        size: context.sp(30),
                                      ),
                                    ),
                                    SizedBox(height: context.sp(14)),
                                    Text(
                                      context.t(
                                        'change_password.hero_subtitle',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: context.sp(14),
                                        color: context.appTextSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.sp(20)),
                              _PasswordField(
                                controller: _currentCtrl,
                                obscure: _obscureCurrent,
                                label: context.t('field.current_password'),
                                onToggle: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                                validator: Validators.password(context),
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: context.sp(16)),
                              _PasswordField(
                                controller: _newCtrl,
                                obscure: _obscureNew,
                                label: context.t('field.new_password'),
                                onToggle: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                                validator: Validators.password(context),
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: context.sp(10)),
                              PasswordStrengthMeter(strength: _strength),
                              SizedBox(height: context.sp(16)),
                              _PasswordField(
                                controller: _confirmCtrl,
                                obscure: _obscureConfirm,
                                label: context.t('field.confirm_password'),
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                validator: Validators.confirmPassword(
                                  context,
                                  _newCtrl.text,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                              ),
                              SizedBox(height: context.sp(18)),
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
                              if (state.isSuccess) ...[
                                SizedBox(height: context.sp(18)),
                                _SuccessBanner(
                                  message: context.t('change_password.success'),
                                  onDismiss: () => ref
                                      .read(
                                        changePasswordControllerProvider
                                            .notifier,
                                      )
                                      .reset(),
                                ),
                              ],
                              if (state.isFailure && state.error != null) ...[
                                SizedBox(height: context.sp(18)),
                                Text(
                                  state.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: context.sp(13),
                                    color: context.appError,
                                  ),
                                ),
                              ],
                              SizedBox(height: context.sp(22)),
                              ElevatedButton(
                                onPressed: state.isSubmitting ? null : _submit,
                                child: state.isSubmitting
                                    ? SizedBox.square(
                                        dimension: context.sp(22),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(context.t('change_password.save')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.label,
    required this.onToggle,
    required this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscure;
  final String label;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(
        fontFamily: 'Almarai',
        color: context.appTextPrimary,
        fontSize: context.sp(15),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: context.appPrimary,
          size: context.sp(20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: context.appPrimary,
            size: context.sp(20),
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(14),
        vertical: context.sp(12),
      ),
      decoration: BoxDecoration(
        color: context.appSuccess.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appSuccess.withAlpha(90)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: context.sp(20),
            color: context.appSuccess,
          ),
          SizedBox(width: context.sp(10)),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                color: context.appSuccess,
              ),
            ),
          ),
          SizedBox(width: context.sp(10)),
          InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(100),
            child: Icon(
              Icons.close_rounded,
              size: context.sp(18),
              color: context.appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
