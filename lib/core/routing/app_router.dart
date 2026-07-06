import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_controller_provider.dart';
import '../../features/auth/presentation/screens/auth_gate_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/providers/splash_provider.dart';

/// Root widget: drives the entire navigation tree from auth + onboarding state.
/// No routing package required — state changes trigger widget swaps.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashDone = ref.watch(splashDoneProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final authStatus =
        ref.watch(authControllerProvider.select((s) => s.status));

    // Always show splash until its animation completes.
    if (!splashDone) return const SplashScreen();

    return switch (authStatus) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.unauthenticated =>
        onboardingDone ? const WelcomeScreen() : const OnboardingScreen(),
      AuthStatus.authenticated => const AuthGateScreen(),
    };
  }
}
