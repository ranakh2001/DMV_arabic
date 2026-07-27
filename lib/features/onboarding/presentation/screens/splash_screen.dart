import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../providers/splash_provider.dart';
import '../widgets/splash_loading_footer.dart';

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
    final accent = context.appPrimary;
    final textColor = context.appTextPrimary;
    final subColor = context.appTextSecondary;

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
                    colors: [context.appSurface, context.appBackground],
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
                    gradient: RadialGradient(colors: [accent.withAlpha(20), Colors.transparent]),
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
                    child: SplashLoadingFooter(progress: _barProgress.value),
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
