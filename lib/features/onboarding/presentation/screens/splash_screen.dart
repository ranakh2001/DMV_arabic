import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _spin;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _tagOpacity;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _barProgress;
  late final Animation<double> _bottomOpacity;

  @override
  void initState() {
    super.initState();

    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.0, 0.42, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.0, 0.22, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.38, 0.60, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _main,
      curve: const Interval(0.38, 0.60, curve: Curves.easeOut),
    ));

    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.50, 0.70, curve: Curves.easeIn),
      ),
    );

    _tagSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _main,
      curve: const Interval(0.50, 0.70, curve: Curves.easeOut),
    ));

    _barProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.52, 0.96, curve: Curves.easeInOut),
      ),
    );

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
      ),
    );

    _main.forward().then((_) {
      if (mounted) ref.read(splashDoneProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _main.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTop =
        isDark ? const Color(0xFF0D1E3A) : const Color(0xFFDEEBF7);
    final bgBot =
        isDark ? const Color(0xFF060D1E) : const Color(0xFFF4F6FB);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final subColor = isDark ? Colors.white54 : const Color(0xFF4A5568);
    final dimColor = isDark ? Colors.white24 : Colors.black26;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _main,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgTop, bgBot],
                  ),
                ),
              ),

              // Soft radial glow in center
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4A9CD9).withAlpha(isDark ? 30 : 15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo badge
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _LogoBadge(spinController: _spin, isDark: isDark),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Text(
                        context.t('app.name'),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _tagOpacity,
                    child: SlideTransition(
                      position: _tagSlide,
                      child: Text(
                        context.t('splash.tagline'),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: subColor,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Loading bar + version
                  FadeTransition(
                    opacity: _bottomOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          // Bar track
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: dimColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: AnimatedContainer(
                                    duration: Duration.zero,
                                    width: constraints.maxWidth *
                                        _barProgress.value,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFF4A9CD9),
                                        Color(0xFF5FC3FF),
                                      ]),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            context.t('splash.version'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: dimColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            context.t('splash.copyright'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: dimColor.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Logo Badge ─────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.spinController, required this.isDark});

  final AnimationController spinController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A9CD9).withAlpha(isDark ? 90 : 50),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Spinning dashed outer ring
          AnimatedBuilder(
            animation: spinController,
            builder: (context, _) => Transform.rotate(
              angle: spinController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(136, 136),
                painter: _DashedRingPainter(
                  color: const Color(0xFF4A9CD9).withAlpha(180),
                ),
              ),
            ),
          ),

          // Static badge body
          CustomPaint(
            size: const Size(110, 110),
            painter: _BadgeBodyPainter(isDark: isDark),
          ),

          // Text content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بالعربي',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'DMV',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 5,
                  height: 1.1,
                ),
              ),
              Text(
                'ARABIA',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  letterSpacing: 3,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeBodyPainter extends CustomPainter {
  const _BadgeBodyPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gradient fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF1C4D8C), const Color(0xFF0A2050)]
            : [const Color(0xFF3A7CC9), const Color(0xFF1A4D8C)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fillPaint);

    // Outer ring
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = const Color(0xFF4A9CD9)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      radius - 9,
      Paint()
        ..color = const Color(0xFF4A9CD9).withAlpha(100)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_BadgeBodyPainter old) => old.isDark != isDark;
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const dashCount = 24;
    const dashAngle = 2 * math.pi / dashCount;
    const gapFraction = 0.4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}
