import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_content_card.dart';
import 'onboarding_floating_badge.dart';
import 'painters/pulse_ring_painter.dart';
import 'painters/steering_wheel_painter.dart';

/// Onboarding slide 1: steering-wheel hero with orbiting feature badges.
class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _floatCtrl2;
  late final AnimationController _entryCtrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _floatAnim2;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _floatCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
    _floatAnim2 = Tween<double>(
      begin: 6,
      end: -6,
    ).animate(CurvedAnimation(parent: _floatCtrl2, curve: Curves.easeInOut));
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _floatCtrl2.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _badge({
    required double top,
    double? left,
    double? right,
    required Animation<double> float,
    required Interval entryCurve,
    required double phaseShift,
    required IconData icon,
    required String label,
  }) {
    final accent = context.appPrimary;
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _entryCtrl, curve: entryCurve),
        child: AnimatedBuilder(
          animation: Listenable.merge([float, _pulseCtrl]),
          builder: (_, child) {
            final g =
                math.sin(_pulseCtrl.value * 2 * math.pi + phaseShift) * 0.5 +
                0.5;
            return Transform.translate(
              offset: Offset(0, float.value),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withAlpha((70 + 80 * g).round()),
                      blurRadius: 16 + 14 * g,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: OnboardingFloatingBadge(icon: icon, label: label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final accent = context.appPrimary;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseCtrl, _floatCtrl]),
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(220, 220),
                              painter: PulseRingPainter(
                                progress: _pulseCtrl.value,
                                color: accent,
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accent.withAlpha(180),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withAlpha(45),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                                gradient: RadialGradient(
                                  colors: [
                                    accent.withAlpha(40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(110, 110),
                              painter: SteeringWheelPainter(color: accent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _badge(
                  top: 10,
                  left: 8,
                  float: _floatAnim,
                  entryCurve: const Interval(
                    0.2,
                    0.7,
                    curve: Curves.elasticOut,
                  ),
                  phaseShift: 0,
                  icon: Icons.quiz_outlined,
                  label: context.t('onboarding.slide1.badge_questions'),
                ),
                _badge(
                  top: 10,
                  right: 8,
                  float: _floatAnim2,
                  entryCurve: const Interval(
                    0.3,
                    0.8,
                    curve: Curves.elasticOut,
                  ),
                  phaseShift: math.pi,
                  icon: Icons.map_outlined,
                  label: context.t('onboarding.slide1.badge_states'),
                ),
                Positioned(
                  bottom: 2,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
                    ),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_floatCtrl, _pulseCtrl]),
                      builder: (_, child) {
                        final g =
                            math.sin(
                                  _pulseCtrl.value * 2 * math.pi +
                                      math.pi * 0.5,
                                ) *
                                0.5 +
                            0.5;
                        return Transform.translate(
                          offset: Offset(0, -_floatAnim.value * 0.65),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withAlpha(
                                    (70 + 80 * g).round(),
                                  ),
                                  blurRadius: 16 + 14 * g,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: OnboardingFloatingBadge(
                        icon: Icons.location_city_rounded,
                        label: context.t('onboarding.slide1.badge_quiz'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          OnboardingContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.t('onboarding.slide1.title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.t('onboarding.slide1.subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 15,
                    color: context.appTextSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }
}
