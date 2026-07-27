import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_field_decoration.dart';
import '../widgets/auth_field_label.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/circle_nav_button.dart';
import '../widgets/glow_elevated_button.dart';
import '../widgets/phone_field.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(loginControllerProvider.notifier).login(contact: _contactCtrl.text.trim(), password: _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    ref.listen(loginControllerProvider, (_, next) {
      if (next.isFailure && (next.error?.startsWith('UNVERIFIED:') ?? false)) {
        final contact = next.error!.replaceFirst('UNVERIFIED:', '');
        ref.read(loginControllerProvider.notifier).reset();
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VerifyScreen(contact: contact)));
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
                        CircleNavButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).maybePop()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.t('auth.login.title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: context.appTextPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.t('auth.login.subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Almarai', fontSize: 14, color: context.appTextSecondary, height: 1.6),
                          ),
                          const SizedBox(height: 36),
                          AuthGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  PhoneField(controller: _contactCtrl, label: context.t('field.phone')),
                                  const SizedBox(height: 20),
                                  AuthFieldLabel(context.t('field.password')),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    style: TextStyle(fontFamily: 'Almarai', color: context.appTextPrimary, fontSize: 15),
                                    decoration: authPasswordDecoration(
                                      context: context,
                                      hint: '••••••••',
                                      obscure: _obscurePassword,
                                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: Validators.password(context),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
                                      ),
                                      child: Text(
                                        context.t('auth.login.forgot'),
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.appPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (state.isFailure && state.error != null && !state.error!.startsWith('UNVERIFIED:'))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        state.error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appError),
                                      ),
                                    ),
                                  GlowElevatedButton(
                                    onPressed: state.isSubmitting ? null : _submit,
                                    label: context.t('auth.login.submit'),
                                    loading: state.isSubmitting,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.t('auth.login.no_account'),
                                style: TextStyle(fontFamily: 'Almarai', fontSize: 14, color: context.appTextSecondary),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
                                ),
                                child: Text(
                                  context.t('auth.login.sign_up'),
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
