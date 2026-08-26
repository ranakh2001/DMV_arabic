import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../states/domain/entities/us_state.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/circle_nav_button.dart';
import '../widgets/register_form.dart';
import 'login_screen.dart';
import 'verify_screen.dart';

int _passwordStrength(String password) {
  if (password.isEmpty) return 0;
  int score = 0;
  if (password.length >= 8) score++;
  if (password.contains(RegExp(r'[A-Z]'))) score++;
  if (password.contains(RegExp(r'[0-9]'))) score++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
  return score;
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  UsState? _selectedState;
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedState == null) {
      _showSnackBar(context.t('validator.state.required'));
      return;
    }
    if (!_termsAccepted) {
      _showSnackBar(
        context.t('auth.register.agree_terms') +
            context.t('auth.register.terms_use'),
      );
      return;
    }
    await ref
        .read(registerControllerProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          contact: _contactCtrl.text.trim(),
          stateId: _selectedState!.id,
          password: _passwordCtrl.text,
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.appPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (_, next) {
      if (next.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => VerifyScreen(contact: _contactCtrl.text.trim()),
          ),
        );
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        CircleNavButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        Text(
                          context.t('auth.register.title'),
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.appTextPrimary,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.t('auth.register.welcome_title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: context.appTextPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.t('auth.register.welcome_subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 14,
                              color: context.appTextSecondary,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 30),
                          RegisterForm(
                            formKey: _formKey,
                            nameCtrl: _nameCtrl,
                            emailCtrl: _emailCtrl,
                            contactCtrl: _contactCtrl,
                            passwordCtrl: _passwordCtrl,
                            confirmCtrl: _confirmCtrl,
                            obscurePassword: _obscurePassword,
                            obscureConfirm: _obscureConfirm,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onToggleConfirm: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            passwordStrength: _pwStrength,
                            selectedState: _selectedState,
                            onStateSelected: (s) =>
                                setState(() => _selectedState = s),
                            termsAccepted: _termsAccepted,
                            onTermsChanged: (v) =>
                                setState(() => _termsAccepted = v ?? false),
                            errorMessage: state.isFailure ? state.error : null,
                            submitting: state.isSubmitting,
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.t('auth.register.have_account'),
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14,
                                  color: context.appTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                                child: Text(
                                  context.t('auth.register.sign_in'),
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: context.appPrimary,
                                  ),
                                ),
                              ),
                            ],
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
