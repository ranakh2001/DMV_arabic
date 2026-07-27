import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_controller_provider.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/providers/splash_provider.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/subscription/presentation/screens/subscription_plans_screen.dart';

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

    // Login/register/verify are pushed as routes on top of this widget, so
    // becoming authenticated alone doesn't bring them back down — pop them
    // off once auth succeeds so the rebuilt home/paywall shows through.
    ref.listen(authControllerProvider.select((s) => s.status), (prev, next) {
      if (next == AuthStatus.authenticated) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    // Always show splash until its animation completes.
    if (!splashDone) return const SplashScreen();

    return switch (authStatus) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.unauthenticated =>
        onboardingDone ? const WelcomeScreen() : const OnboardingScreen(),
      AuthStatus.authenticated => _AuthenticatedRoot(),
    };
  }
}

/// Once signed in: the paywall gates the home shell until the user
/// subscribes or dismisses it for this session.
class _AuthenticatedRoot extends ConsumerWidget {
  const _AuthenticatedRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(subscriptionProvider.select((s) => s.isSubscribed));
    final paywallDismissed = ref.watch(paywallDismissedProvider);

    if (!isSubscribed && !paywallDismissed) {
      return const SubscriptionPlansScreen();
    }
    return const MainShellScreen();
  }
}
