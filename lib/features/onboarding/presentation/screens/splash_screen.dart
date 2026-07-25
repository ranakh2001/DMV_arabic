import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _main;

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

                  // Logo
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const AppLogo(),
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
