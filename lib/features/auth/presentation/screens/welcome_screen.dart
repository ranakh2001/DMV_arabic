import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../widgets/auth_entrance.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/glow_elevated_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradientBackground(),
          SafeArea(
            child: AuthEntrance(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(),
                        const SizedBox(height: 22),
                        Text(
                          context.t('app.name'),
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: context.appTextPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: AuthGlassCard(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.t('auth.welcome.greeting'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: context.appTextPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.t('auth.welcome.subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 14,
                              color: context.appTextSecondary,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 30),
                          GlowElevatedButton(
                            label: context.t('auth.welcome.login_btn'),
                            icon: Icons.login_rounded,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.appTextPrimary,
                                side: BorderSide(color: context.appTextDisabled, width: 1.2),
                              ),
                              child: Text(
                                context.t('auth.welcome.register_btn'),
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: context.appTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 18, 32, 20),
                    child: Text(
                      context.t('auth.welcome.terms'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 12,
                        color: context.appTextSecondary,
                        height: 1.5,
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
