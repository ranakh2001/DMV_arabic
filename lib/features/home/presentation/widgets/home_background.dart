import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Gradient backdrop with soft decorative blobs, tuned per theme so the
/// glass cards placed on top of it always have something to blur.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.appPrimary;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColorsDark.background, const Color(0xFF060912)]
              : [const Color(0xFFE9F0FB), AppColorsLight.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: _Blob(color: primary.withAlpha(isDark ? 55 : 35), size: 300),
          ),
          Positioned(
            top: 160,
            right: -80,
            child: _Blob(color: context.appSecondary.withAlpha(isDark ? 35 : 25), size: 220),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
