import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A small badge orbiting the hero icon rings (e.g. the lock on the
/// "forgot password" mail icon, or the mail/check marks on the OTP icon).
class HeroBadge {
  const HeroBadge({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.icon,
    this.size = 30,
    this.iconSize = 14,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final IconData icon;
  final double size;
  final double iconSize;
}

/// The circular hero icon used at the top of every forgot-password screen:
/// two concentric rings with an orbiting accent dot, a gently breathing
/// center circle, and the whole thing floats up and down.
class AnimatedHeroIcon extends StatefulWidget {
  const AnimatedHeroIcon({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconSize = 38,
    this.badges = const [],
  });

  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final List<HeroBadge> badges;

  @override
  State<AnimatedHeroIcon> createState() => _AnimatedHeroIconState();
}

class _AnimatedHeroIconState extends State<AnimatedHeroIcon>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _float;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _float = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _pulse = Tween<double>(
      begin: 0.97,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _ring({
    required double size,
    required int borderAlpha,
    required double dotSize,
    required Color color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(borderAlpha), width: 1),
            ),
          ),
          Positioned(
            top: -dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(140),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? context.appPrimary;
    final badgeFill = context.appSurface;

    return AnimatedBuilder(
      animation: Listenable.merge([_float, _spinCtrl, _pulse]),
      builder: (context, _) {
        final spinAngle = _spinCtrl.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: spinAngle,
                  child: _ring(
                    size: 176,
                    borderAlpha: 22,
                    dotSize: 8,
                    color: color,
                  ),
                ),
                Transform.rotate(
                  angle: -spinAngle * 1.6,
                  child: _ring(
                    size: 130,
                    borderAlpha: 45,
                    dotSize: 6,
                    color: color,
                  ),
                ),
                Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeFill,
                      border: Border.all(
                        color: color.withAlpha(90),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(60),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: color,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
                for (final badge in widget.badges)
                  Positioned(
                    top: badge.top,
                    left: badge.left,
                    right: badge.right,
                    bottom: badge.bottom,
                    child: Container(
                      width: badge.size,
                      height: badge.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeFill,
                        border: Border.all(
                          color: color.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          badge.icon,
                          color: color,
                          size: badge.iconSize,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
