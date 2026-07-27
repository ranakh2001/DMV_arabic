import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller_provider.dart';
import '../widgets/animated_hero_icon.dart';
import '../widgets/auth_badge_chip.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/glow_elevated_button.dart';
import '../widgets/phone_field.dart';
import 'forgot_verify_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(forgotPasswordControllerProvider.notifier)
        .send(contact: _phoneCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    ref.listen(forgotPasswordControllerProvider, (_, next) {
      if (next.isSuccess) {
        ref.read(forgotPasswordControllerProvider.notifier).reset();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ForgotVerifyScreen(contact: _phoneCtrl.text.trim()),
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

                          AuthGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: AuthBadgeChip(
                                      label: context.t('auth.forgot.badge'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.t('auth.forgot.question'),
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
                                    context.t('auth.forgot.phone_subtitle'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 13,
                                      color: context.appTextSecondary,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  PhoneField(
                                    controller: _phoneCtrl,
                                    hint: '0000000000000',
                                    iconStyle: PhoneFieldIconStyle.suffix,
                                    textInputAction: TextInputAction.done,
                                    textDirection: TextDirection.ltr,
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  const SizedBox(height: 16),

                                  if (state.isFailure && state.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        state.error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 13,
                                          color: context.appError,
                                        ),
                                      ),
                                    ),

                                  GlowElevatedButton(
                                    onPressed: _submit,
                                    icon: Icons.send_rounded,
                                    label: context.t('auth.forgot.send_code'),
                                    loading: state.isSubmitting,
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
                                  color: context.appTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                child: Text(
                                  context.t('auth.forgot.sign_in_link'),
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
