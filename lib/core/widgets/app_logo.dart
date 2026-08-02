import 'package:flutter/material.dart';

/// Shared app logo: image with an ambient glow behind it.
/// Used on the splash and welcome screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 140,
    this.glowSize = 160,
    this.glowAlpha = 70,
  });

  final double size;
  final double glowSize;
  final int glowAlpha;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: glowSize,
          height: glowSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A9CD9).withAlpha(glowAlpha),
                blurRadius: 80,
                spreadRadius: 12,
              ),
            ],
          ),
        ),
        Image.asset('assets/logo/logo.png', width: size, fit: BoxFit.contain),
      ],
    );
  }
}
