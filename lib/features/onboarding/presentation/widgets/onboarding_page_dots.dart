import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Row of dot indicators for the onboarding [PageView], the active one
/// stretched into a pill.
class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? accent : accent.withAlpha(70),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
