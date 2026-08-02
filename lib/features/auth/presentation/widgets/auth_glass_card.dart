import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// The frosted card every auth-flow form sits on. Uses a stronger blur and
/// higher fill opacity than [GlassContainer]'s app-wide default so form
/// fields stay legible over the flow's gradient + blob background.
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return GlassContainer(
      radius: 24,
      blur: 22,
      opacity: 0.9,
      tint: context.appSurface,
      border: accent.withAlpha(90),
      padding: padding ?? const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(60),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: accent.withAlpha(18),
          blurRadius: 26,
          spreadRadius: -4,
        ),
      ],
      child: child,
    );
  }
}
