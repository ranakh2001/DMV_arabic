import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_content_card.dart';
import 'onboarding_feature_icon.dart';
import 'painters/circular_progress_painter.dart';

/// Onboarding slide 2: an animated card-stack + progress illustration.
class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _progressAnim = Tween<double>(
      begin: 0.80,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),
          const Spacer(),
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: Listenable.merge([_cardCtrl, _progressCtrl]),
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _BackCard(
                      dx: -62,
                      dy: 14,
                      rotation: -0.16,
                      anim: CurvedAnimation(
                        parent: _cardCtrl,
                        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
                      ),
                    ),
                    _BackCard(
                      dx: 62,
                      dy: 14,
                      rotation: 0.16,
                      anim: CurvedAnimation(
                        parent: _cardCtrl,
                        curve: const Interval(0.1, 0.75, curve: Curves.easeOut),
                      ),
                    ),
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _cardCtrl,
                        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                      ),
                      child: _FrontCard(progress: _progressAnim.value),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          OnboardingContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.t('onboarding.slide2.title'),
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
                  context.t('onboarding.slide2.subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 15,
                    color: context.appTextSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OnboardingFeatureIcon(
                      emoji: '🧠',
                      label: context.t('onboarding.slide2.feat1'),
                    ),
                    OnboardingFeatureIcon(
                      emoji: '⏱️',
                      label: context.t('onboarding.slide2.feat2'),
                    ),
                    OnboardingFeatureIcon(
                      emoji: '📊',
                      label: context.t('onboarding.slide2.feat3'),
                    ),
                  ],
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

class _BackCard extends StatelessWidget {
  const _BackCard({
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.anim,
  });

  final double dx;
  final double dy;
  final double rotation;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: anim,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: 244,
            height: 138,
            decoration: BoxDecoration(
              color: context.appSurface.withAlpha(215),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.appPrimary.withAlpha(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  const _FrontCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 268,
          height: 155,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withAlpha(80)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(90),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: accent.withAlpha(35),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(92, 92),
                      painter: CircularProgressPainter(
                        progress: progress,
                        color: accent,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.appTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: context.appTextSecondary.withAlpha(38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 10,
                      width: 72,
                      decoration: BoxDecoration(
                        color: context.appTextSecondary.withAlpha(22),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -16,
          right: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withAlpha(160), width: 1.5),
              boxShadow: [
                BoxShadow(color: accent.withAlpha(80), blurRadius: 18),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: accent),
                const SizedBox(width: 5),
                Text(
                  '00:45',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
