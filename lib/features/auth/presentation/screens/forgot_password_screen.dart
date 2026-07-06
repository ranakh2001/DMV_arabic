import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/forgot_password_widgets.dart';
import 'forgot_verify_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotVerifyScreen(contact: _phoneCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AuthFlowBackground(isDark: isDark),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  AuthTopBar(
                    title: context.t('auth.forgot.title'),
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
                              icon: Icons.mail_rounded,
                              badges: const [
                                HeroBadge(
                                  bottom: 34,
                                  right: 34,
                                  icon: Icons.lock_rounded,
                                ),
                              ],
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
                                      label: context.t('auth.forgot.badge'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.t('auth.forgot.question'),
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
                                    context.t('auth.forgot.phone_subtitle'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(155),
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    textDirection: TextDirection.ltr,
                                    onFieldSubmitted: (_) => _submit(),
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: authFieldDecoration(
                                      context: context,
                                      hint: '0000000000000',
                                      suffixIcon: const Icon(
                                        Icons.phone_rounded,
                                        color: Color(0xFF4A9CD9),
                                        size: 20,
                                      ),
                                    ),
                                    validator: Validators.emailOrPhone(context),
                                  ),
                                  const SizedBox(height: 24),

                                  GlowElevatedButton(
                                    onPressed: _submit,
                                    icon: Icons.send_rounded,
                                    label: context.t('auth.forgot.send_code'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.t('auth.forgot.remember'),
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(140),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                child: Text(
                                  context.t('auth.forgot.sign_in_link'),
                                  style: const TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4A9CD9),
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
