import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Gradient backdrop with two soft decorative blobs, shared by every
/// pre-auth screen (welcome, login, register, forgot-password flow).
class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key, this.mirrored = false});

  /// Flips the blob positions so consecutive screens in a flow feel
  /// slightly different without duplicating the whole widget.
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [context.appSurface, context.appBackground],
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: mirrored ? null : -60,
          right: mirrored ? -60 : null,
          child: _Blob(color: context.appPrimary.withAlpha(50), size: 260),
        ),
        Positioned(
          bottom: -50,
          right: mirrored ? null : -50,
          left: mirrored ? -40 : null,
          child: _Blob(color: context.appSecondary.withAlpha(25), size: 200),
        ),
      ],
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
