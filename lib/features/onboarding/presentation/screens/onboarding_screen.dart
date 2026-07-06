import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../providers/onboarding_provider.dart';

// ─── US States ───────────────────────────────────────────────────────────────

const _usStates = [
  ('Alabama', 'ألاباما'),
  ('Alaska', 'ألاسكا'),
  ('Arizona', 'أريزونا'),
  ('Arkansas', 'أركنساس'),
  ('California', 'كاليفورنيا'),
  ('Colorado', 'كولورادو'),
  ('Connecticut', 'كونيتيكت'),
  ('Delaware', 'ديلاوير'),
  ('Florida', 'فلوريدا'),
  ('Georgia', 'جورجيا'),
  ('Hawaii', 'هاواي'),
  ('Idaho', 'أيداهو'),
  ('Illinois', 'إلينوي'),
  ('Indiana', 'إنديانا'),
  ('Iowa', 'آيوا'),
  ('Kansas', 'كانساس'),
  ('Kentucky', 'كنتاكي'),
  ('Louisiana', 'لويزيانا'),
  ('Maine', 'مين'),
  ('Maryland', 'ماريلاند'),
  ('Massachusetts', 'ماساتشوستس'),
  ('Michigan', 'ميشيغان'),
  ('Minnesota', 'مينيسوتا'),
  ('Mississippi', 'ميسيسيبي'),
  ('Missouri', 'ميسوري'),
  ('Montana', 'مونتانا'),
  ('Nebraska', 'نيبراسكا'),
  ('Nevada', 'نيفادا'),
  ('New Hampshire', 'نيو هامبشير'),
  ('New Jersey', 'نيوجيرسي'),
  ('New Mexico', 'نيو مكسيكو'),
  ('New York', 'نيويورك'),
  ('North Carolina', 'كارولينا الشمالية'),
  ('North Dakota', 'داكوتا الشمالية'),
  ('Ohio', 'أوهايو'),
  ('Oklahoma', 'أوكلاهوما'),
  ('Oregon', 'أوريغون'),
  ('Pennsylvania', 'بنسلفانيا'),
  ('Rhode Island', 'رود آيلاند'),
  ('South Carolina', 'كارولينا الجنوبية'),
  ('South Dakota', 'داكوتا الجنوبية'),
  ('Tennessee', 'تينيسي'),
  ('Texas', 'تكساس'),
  ('Utah', 'يوتا'),
  ('Vermont', 'فيرمونت'),
  ('Virginia', 'فيرجينيا'),
  ('Washington', 'واشنطن'),
  ('West Virginia', 'فيرجينيا الغربية'),
  ('Wisconsin', 'ويسكونسن'),
  ('Wyoming', 'وايومنغ'),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  String? _selectedState;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_currentPage == 2 && _selectedState == null) return;
    if (_selectedState != null) {
      await ref.read(prefsServiceProvider).setSelectedState(_selectedState!);
    }
    await ref.read(onboardingDoneProvider.notifier).complete();
  }

  Future<void> _goToLogin() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final bgTop = isDark ? const Color(0xFF0D1E3A) : const Color(0xFFDBEAF5);
    final bgBot = isDark ? const Color(0xFF060D1E) : const Color(0xFFF4F6FB);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBot],
              ),
            ),
          ),

          // Starfield (all pages)
          const Positioned.fill(child: _StarfieldOverlay()),

          // Pages
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _Page1(isDark: isDark),
              _Page2(isDark: isDark),
              _Page3(
                isDark: isDark,
                isAr: isAr,
                selectedState: _selectedState,
                onStateChanged: (s) => setState(() => _selectedState = s),
              ),
            ],
          ),

          // Bottom overlay: dots + buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              selectedState: _selectedState,
              onNext: _goNext,
              onSkip: _skip,
              onLogin: _goToLogin,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Controls ─────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.selectedState,
    required this.onNext,
    required this.onSkip,
    required this.onLogin,
    required this.isDark,
  });

  final int currentPage;
  final String? selectedState;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onLogin;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == 2;
    final canProceed = !isLastPage || selectedState != null;
    final textSecondary =
        isDark ? Colors.white38 : const Color(0xFF4A5568).withAlpha(180);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page dots
            _PageDots(current: currentPage, total: 3),

            const SizedBox(height: 20),

            // Primary button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: AnimatedOpacity(
                opacity: canProceed ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 250),
                child: ElevatedButton(
                  onPressed: canProceed ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9CD9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage
                            ? context.t('onboarding.start')
                            : currentPage == 0
                                ? context.t('onboarding.slide1.cta')
                                : context.t('common.next'),
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isLastPage) ...[
                        const SizedBox(width: 6),
                        const Text('🚗', style: TextStyle(fontSize: 18)),
                      ] else ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Secondary link
            if (isLastPage)
              GestureDetector(
                onTap: onLogin,
                child: Text(
                  context.t('onboarding.have_account'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    color: textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: textSecondary,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  context.t('common.skip'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 15,
                    color: textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Page Dots ───────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF4A9CD9)
                : const Color(0xFF4A9CD9).withAlpha(70),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Shared Content Card ─────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D1E3A).withAlpha(210)
                  : Colors.white.withAlpha(215),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4A9CD9).withAlpha(70)
                    : const Color(0xFF4A9CD9).withAlpha(100),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 80 : 25),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF4A9CD9).withAlpha(isDark ? 35 : 18),
                  blurRadius: 24,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Starfield Overlay ───────────────────────────────────────────────────────

class _StarfieldOverlay extends StatefulWidget {
  const _StarfieldOverlay();

  @override
  State<_StarfieldOverlay> createState() => _StarfieldOverlayState();
}

class _StarfieldOverlayState extends State<_StarfieldOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        painter: _StarlightPainter(progress: _ctrl.value),
      ),
    );
  }
}

// ─── Page 1: Intro ───────────────────────────────────────────────────────────

class _Page1 extends StatefulWidget {
  const _Page1({required this.isDark});
  final bool isDark;

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> with TickerProviderStateMixin {
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

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _floatAnim2 = Tween<double>(begin: 6, end: -6).animate(
      CurvedAnimation(parent: _floatCtrl2, curve: Curves.easeInOut),
    );

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textPrimary =
        widget.isDark ? Colors.white : const Color(0xFF0D1B3E);
    final textSecondary =
        widget.isDark ? Colors.white70 : const Color(0xFF4A5568);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),

          const Spacer(),

          // Hero: steering wheel + floating badges
          SizedBox(
            width: double.infinity,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Steering wheel with pulse & float
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
                              painter: _PulseRingPainter(
                                progress: _pulseCtrl.value,
                                color: const Color(0xFF4A9CD9),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4A9CD9)
                                      .withAlpha(180),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A9CD9).withAlpha(
                                        widget.isDark ? 60 : 30),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF4A9CD9).withAlpha(40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(110, 110),
                              painter: _SteeringWheelPainter(
                                color: const Color(0xFF4A9CD9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Badge – top-left: +250 (swimming + glow)
                Positioned(
                  top: 10,
                  left: 8,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.2, 0.7,
                          curve: Curves.elasticOut),
                    ),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_floatCtrl, _pulseCtrl]),
                      builder: (_, child) {
                        final g = math.sin(_pulseCtrl.value * 2 * math.pi) * 0.5 + 0.5;
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A9CD9)
                                      .withAlpha((70 + 80 * g).round()),
                                  blurRadius: 16 + 14 * g,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _FloatingBadge(
                        icon: Icons.quiz_outlined,
                        label: context.t('onboarding.slide1.badge_questions'),
                        isDark: widget.isDark,
                      ),
                    ),
                  ),
                ),

                // Badge – top-right: 50 States (swimming + glow, opposite phase)
                Positioned(
                  top: 10,
                  right: 8,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.3, 0.8,
                          curve: Curves.elasticOut),
                    ),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_floatCtrl2, _pulseCtrl]),
                      builder: (_, child) {
                        final g = math.sin(_pulseCtrl.value * 2 * math.pi + math.pi) * 0.5 + 0.5;
                        return Transform.translate(
                          offset: Offset(0, _floatAnim2.value),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A9CD9)
                                      .withAlpha((70 + 80 * g).round()),
                                  blurRadius: 16 + 14 * g,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _FloatingBadge(
                        icon: Icons.map_outlined,
                        label: context.t('onboarding.slide1.badge_states'),
                        isDark: widget.isDark,
                      ),
                    ),
                  ),
                ),

                // Badge – bottom-center: balance
                Positioned(
                  bottom: 2,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.5, 1.0,
                          curve: Curves.elasticOut),
                    ),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_floatCtrl, _pulseCtrl]),
                      builder: (_, child) {
                        final g = math.sin(_pulseCtrl.value * 2 * math.pi + math.pi * 0.5) * 0.5 + 0.5;
                        return Transform.translate(
                          offset: Offset(0, -_floatAnim.value * 0.65),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A9CD9)
                                      .withAlpha((70 + 80 * g).round()),
                                  blurRadius: 16 + 14 * g,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _FloatingBadge(
                        icon: Icons.location_city_rounded,
                        label: context.t('onboarding.slide1.badge_quiz'),
                        isDark: widget.isDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Content card
          _ContentCard(
            isDark: widget.isDark,
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
                    color: textPrimary,
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
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
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

// ─── Starlight Painter ───────────────────────────────────────────────────────

class _StarlightPainter extends CustomPainter {
  const _StarlightPainter({required this.progress});
  final double progress;

  // (x%, y%, radius, twinklePhase)
  static const _stars = [
    (0.08, 0.06, 2.2, 0.00),
    (0.23, 0.13, 1.6, 0.28),
    (0.72, 0.09, 2.6, 0.55),
    (0.88, 0.18, 1.8, 0.10),
    (0.14, 0.38, 2.0, 0.72),
    (0.84, 0.32, 2.2, 0.42),
    (0.04, 0.58, 1.6, 0.65),
    (0.93, 0.52, 2.4, 0.20),
    (0.32, 0.78, 1.8, 0.88),
    (0.68, 0.74, 2.0, 0.50),
    (0.50, 0.11, 1.6, 0.15),
    (0.42, 0.90, 2.0, 0.62),
    (0.78, 0.65, 1.6, 0.33),
    (0.11, 0.84, 2.2, 0.47),
    (0.36, 0.25, 1.8, 0.05),
    (0.96, 0.78, 2.0, 0.38),
    (0.60, 0.44, 1.4, 0.78),
    (0.55, 0.60, 1.4, 0.90),
  ];

  // (x1%, y1%, x2%, y2%)  — long diagonal lines radiating from edges
  static const _lines = [
    // From top-left corner
    (0.00, 0.00, 0.58, 0.36),
    (0.00, 0.04, 0.42, 0.52),
    // From top-right corner
    (1.00, 0.00, 0.43, 0.40),
    (1.00, 0.07, 0.62, 0.48),
    // From left mid-edge
    (0.00, 0.38, 0.36, 0.18),
    (0.00, 0.56, 0.28, 0.76),
    // From right mid-edge
    (1.00, 0.35, 0.64, 0.16),
    (1.00, 0.60, 0.68, 0.82),
    // From bottom edges
    (0.10, 1.00, 0.44, 0.66),
    (0.90, 1.00, 0.56, 0.63),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle geometric lines
    final linePaint = Paint()
      ..color = const Color(0xFF4A9CD9).withAlpha(28)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (final l in _lines) {
      canvas.drawLine(
        Offset(l.$1 * w, l.$2 * h),
        Offset(l.$3 * w, l.$4 * h),
        linePaint,
      );
    }

    // Twinkling stars
    for (final s in _stars) {
      final twinkle = math.sin((progress + s.$4) * 2 * math.pi) * 0.5 + 0.5;
      final alpha = (70 + 140 * twinkle).round();
      final r = s.$3 * (0.75 + 0.25 * twinkle);
      final cx = s.$1 * w;
      final cy = s.$2 * h;

      // Soft glow halo
      canvas.drawCircle(
        Offset(cx, cy),
        r * 4,
        Paint()
          ..color = const Color(0xFF4A9CD9)
              .withAlpha((22 * twinkle).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Core dot
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.white.withAlpha(alpha),
      );

      // 4-point sparkle arms for bigger stars
      if (s.$3 > 1.9) {
        final arm = r * 3.5 * (0.4 + 0.6 * twinkle);
        final armPaint = Paint()
          ..color = Colors.white.withAlpha((alpha * 0.35).round())
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), armPaint);
        canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), armPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarlightPainter old) => old.progress != progress;
}

// ─── Floating Badge ───────────────────────────────────────────────────────────

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1E3A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF4A9CD9).withAlpha(130),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF4A9CD9).withAlpha(isDark ? 70 : 40),
            blurRadius: 14,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4A9CD9), size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A9CD9),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Features ────────────────────────────────────────────────────────

class _Page2 extends StatefulWidget {
  const _Page2({required this.isDark});
  final bool isDark;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> with TickerProviderStateMixin {
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

    _progressAnim = Tween<double>(begin: 0.80, end: 0.96).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
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
    final textPrimary =
        widget.isDark ? Colors.white : const Color(0xFF0D1B3E);
    final textSecondary =
        widget.isDark ? Colors.white70 : const Color(0xFF4A5568);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),

          const Spacer(),

          // Card stack illustration
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: Listenable.merge([_cardCtrl, _progressCtrl]),
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Back card – left / tilted
                    _buildBackCard(
                      dx: -62,
                      dy: 14,
                      rotation: -0.16,
                      anim: CurvedAnimation(
                        parent: _cardCtrl,
                        curve:
                            const Interval(0.0, 0.65, curve: Curves.easeOut),
                      ),
                    ),
                    // Back card – right / tilted
                    _buildBackCard(
                      dx: 62,
                      dy: 14,
                      rotation: 0.16,
                      anim: CurvedAnimation(
                        parent: _cardCtrl,
                        curve:
                            const Interval(0.1, 0.75, curve: Curves.easeOut),
                      ),
                    ),
                    // Front card with progress & timer badge
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _cardCtrl,
                        curve:
                            const Interval(0.2, 1.0, curve: Curves.easeOut),
                      ),
                      child: _buildFrontCard(),
                    ),
                  ],
                );
              },
            ),
          ),

          const Spacer(),

          // Content card
          _ContentCard(
            isDark: widget.isDark,
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
                    color: textPrimary,
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
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FeatureIcon(
                      emoji: '🧠',
                      label: context.t('onboarding.slide2.feat1'),
                      isDark: widget.isDark,
                    ),
                    _FeatureIcon(
                      emoji: '⏱️',
                      label: context.t('onboarding.slide2.feat2'),
                      isDark: widget.isDark,
                    ),
                    _FeatureIcon(
                      emoji: '📊',
                      label: context.t('onboarding.slide2.feat3'),
                      isDark: widget.isDark,
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

  Widget _buildBackCard({
    required double dx,
    required double dy,
    required double rotation,
    required Animation<double> anim,
  }) {
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
              color: widget.isDark
                  ? const Color(0xFF071020).withAlpha(215)
                  : const Color(0xFFECF3FA).withAlpha(215),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF4A9CD9).withAlpha(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(widget.isDark ? 90 : 20),
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

  Widget _buildFrontCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card body
        Container(
          width: 268,
          height: 155,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF0D1E3A).withAlpha(245)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4A9CD9).withAlpha(80),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(widget.isDark ? 130 : 45),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF4A9CD9)
                    .withAlpha(widget.isDark ? 50 : 25),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular progress
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(92, 92),
                      painter: _CircularProgressPainter(
                        progress: _progressAnim.value,
                        color: const Color(0xFF4A9CD9),
                      ),
                    ),
                    Text(
                      '${(_progressAnim.value * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF0D1B3E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Placeholder content lines
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color:
                            (widget.isDark ? Colors.white : Colors.black)
                                .withAlpha(38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 10,
                      width: 72,
                      decoration: BoxDecoration(
                        color:
                            (widget.isDark ? Colors.white : Colors.black)
                                .withAlpha(22),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Timer badge – overlapping top-right corner
        Positioned(
          top: -16,
          right: -12,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF060F1F)
                  : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF4A9CD9).withAlpha(160),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A9CD9).withAlpha(80),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    size: 14, color: Color(0xFF4A9CD9)),
                SizedBox(width: 5),
                Text(
                  '00:45',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A9CD9),
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

// ─── Page 3: State Selection ─────────────────────────────────────────────────

class _Page3 extends StatefulWidget {
  const _Page3({
    required this.isDark,
    required this.isAr,
    required this.selectedState,
    required this.onStateChanged,
  });

  final bool isDark;
  final bool isAr;
  final String? selectedState;
  final ValueChanged<String?> onStateChanged;

  @override
  State<_Page3> createState() => _Page3State();
}

class _Page3State extends State<_Page3> with SingleTickerProviderStateMixin {
  late final AnimationController _pinsCtrl;

  static const _pinPositions = [
    (0.12, 0.20),  // Washington
    (0.06, 0.44),  // California
    (0.44, 0.12),  // Minnesota
    (0.72, 0.22),  // New York
    (0.66, 0.40),  // Virginia
    (0.60, 0.62),  // Georgia
    (0.27, 0.58),  // Texas
  ];

  @override
  void initState() {
    super.initState();
    _pinsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _pinsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textPrimary =
        widget.isDark ? Colors.white : const Color(0xFF0D1B3E);
    final textSecondary =
        widget.isDark ? Colors.white70 : const Color(0xFF4A5568);
    final hintColor =
        widget.isDark ? Colors.white38 : const Color(0xFF4A5568).withAlpha(160);
    final isAr = widget.isAr;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),

          // Map illustration with animated pins
          Expanded(
            child: AnimatedBuilder(
              animation: _pinsCtrl,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return Stack(
                      children: [
                        // Map grid background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MapGridPainter(
                              color: widget.isDark
                                  ? Colors.white.withAlpha(8)
                                  : Colors.black.withAlpha(5),
                            ),
                          ),
                        ),

                        // US outline
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _UsOutlinePainter(
                              color:
                                  const Color(0xFF4A9CD9).withAlpha(55),
                            ),
                          ),
                        ),

                        // Golden ambient glow – Texas / Oklahoma region
                        Positioned(
                          left: w * 0.16,
                          top: h * 0.35,
                          child: Container(
                            width: w * 0.58,
                            height: h * 0.50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFD4860A).withAlpha(95),
                                  const Color(0xFFD4860A).withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Location pins
                        Stack(
                          children: [
                            for (var i = 0;
                                i < _pinPositions.length;
                                i++)
                              _AnimatedPin(
                                x: _pinPositions[i].$1 * w,
                                y: _pinPositions[i].$2 * h,
                                delay: i / _pinPositions.length,
                                controller: _pinsCtrl,
                                color: const Color(0xFF4A9CD9),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Content card
          _ContentCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('onboarding.slide3.title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('onboarding.slide3.subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // State dropdown
                GestureDetector(
                  onTap: () => _showStatePicker(context, isAr),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF0A2050).withAlpha(200)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.selectedState != null
                            ? const Color(0xFF4A9CD9)
                            : const Color(0xFF4A9CD9).withAlpha(80),
                        width: widget.selectedState != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          color: const Color(0xFF4A9CD9),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.selectedState ??
                                context.t('onboarding.slide3.placeholder'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 15,
                              color: widget.selectedState != null
                                  ? textPrimary
                                  : hintColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF4A9CD9),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Hint text
                Text(
                  context.t('onboarding.slide3.hint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: hintColor,
                    height: 1.4,
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

  void _showStatePicker(BuildContext context, bool isAr) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatePickerSheet(
        isDark: widget.isDark,
        isAr: isAr,
        currentValue: widget.selectedState,
        onSelected: (val) {
          Navigator.pop(context);
          widget.onStateChanged(val);
        },
      ),
    );
  }
}

// ─── State Picker Sheet ───────────────────────────────────────────────────────

class _StatePickerSheet extends StatefulWidget {
  const _StatePickerSheet({
    required this.isDark,
    required this.isAr,
    required this.currentValue,
    required this.onSelected,
  });

  final bool isDark;
  final bool isAr;
  final String? currentValue;
  final ValueChanged<String> onSelected;

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<(String, String)> _filtered = _usStates;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = _usStates
          .where((s) =>
              s.$1.toLowerCase().contains(lower) ||
              s.$2.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isDark ? const Color(0xFF0D1E3A) : Colors.white;
    final textColor =
        widget.isDark ? Colors.white : const Color(0xFF0D1B3E);
    final dividerColor =
        widget.isDark ? Colors.white12 : Colors.black12;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: const Color(0xFF4A9CD9).withAlpha(60),
            ),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9CD9).withAlpha(120),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    color: textColor,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: context.t('onboarding.slide3.search'),
                    hintStyle: TextStyle(
                      fontFamily: 'Almarai',
                      color: textColor.withAlpha(100),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF4A9CD9)),
                    filled: true,
                    fillColor: widget.isDark
                        ? const Color(0xFF0A2050)
                        : const Color(0xFFF0F4F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Divider(color: dividerColor, height: 1),

              // State list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final state = _filtered[i];
                    final displayName =
                        widget.isAr ? state.$2 : state.$1;
                    final isSelected = widget.currentValue == displayName;

                    return InkWell(
                      onTap: () => widget.onSelected(displayName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4A9CD9).withAlpha(30)
                              : Colors.transparent,
                          border: Border(
                              bottom: BorderSide(color: dividerColor)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF4A9CD9)
                                      : textColor,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_rounded,
                                  color: Color(0xFF4A9CD9), size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon(
      {required this.emoji, required this.label, required this.isDark});
  final String emoji;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4A9CD9).withAlpha(isDark ? 30 : 20),
            border: Border.all(color: const Color(0xFF4A9CD9).withAlpha(80)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }
}

// ─── Animated Pin ─────────────────────────────────────────────────────────────

class _AnimatedPin extends StatelessWidget {
  const _AnimatedPin({
    required this.x,
    required this.y,
    required this.delay,
    required this.controller,
    required this.color,
  });

  final double x;
  final double y;
  final double delay;
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0),
          curve: Curves.elasticOut),
    );

    return Positioned(
      left: x - 10,
      top: y - 22,
      child: ScaleTransition(
        scale: anim,
        alignment: Alignment.bottomCenter,
        child: Icon(
          Icons.location_on_rounded,
          color: color,
          size: 22,
          shadows: [
            Shadow(
              color: color.withAlpha(120),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

class _SteeringWheelPainter extends CustomPainter {
  const _SteeringWheelPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer rim
    canvas.drawCircle(Offset(cx, cy), r * 0.90, paint);

    // Center hub
    canvas.drawCircle(
        Offset(cx, cy), r * 0.18, paint..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy), r * 0.18, paint..style = PaintingStyle.stroke);

    // Three spokes at 90°, 210°, 330°
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    for (int i = 0; i < 3; i++) {
      final angle = (90.0 + i * 120.0) * math.pi / 180.0;
      canvas.drawLine(
        Offset(cx + r * 0.18 * math.cos(angle), cy + r * 0.18 * math.sin(angle)),
        Offset(cx + r * 0.90 * math.cos(angle), cy + r * 0.90 * math.sin(angle)),
        paint,
      );
    }

    // Steam / wave lines above (3 arcs)
    final wavePaint = Paint()
      ..color = color.withAlpha(160)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final startX = cx - 18 + i * 18.0;
      final startY = cy - r * 0.90 - 8;
      final path = Path()
        ..moveTo(startX, startY)
        ..cubicTo(
          startX - 6, startY - 8,
          startX + 6, startY - 16,
          startX, startY - 24,
        );
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(_SteeringWheelPainter old) => old.color != color;
}

class _PulseRingPainter extends CustomPainter {
  const _PulseRingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final p = ((progress + i / 3.0) % 1.0);
      final radius = maxR * 0.35 + maxR * 0.65 * p;
      final opacity = (1 - p) * 0.35;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withAlpha((opacity * 255).round())
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) =>
      old.progress != progress || old.color != color;
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter(
      {required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withAlpha(40)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress || old.color != color;
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => old.color != color;
}

class _UsOutlinePainter extends CustomPainter {
  const _UsOutlinePainter({required this.color});
  final Color color;

  // Geographic coordinate space: x ∈ [0,100] (lon –124.8° → –66.9°),
  // y ∈ [0,60] (lat 49.0° → 24.5°). Traced clockwise from NW corner.
  static const List<(double, double)> _outline = [
    // ── Pacific coast (south) ──────────────────────────────────────────
    (0.2, 1.5),  (0.2, 2.9),  (1.4, 6.9),
    (0.9, 11.8), (0.4, 15.0), (0.7, 19.6),
    (3.8, 27.5), (4.8, 30.4), (7.4, 35.5),
    (11.4, 36.8),(13.2, 39.7),
    // ── Southern border (east) ─────────────────────────────────────────
    (13.3, 40.2),(17.3, 40.2),(23.7, 43.1),
    (31.7, 41.9),(41.4, 47.8),(43.8, 52.5),
    (47.2, 56.7),
    // ── Gulf Coast ─────────────────────────────────────────────────────
    (47.4, 52.5),(51.9, 48.8),(53.5, 47.3),
    (55.0, 48.0),(60.0, 47.3),(61.4, 49.8),  // Louisiana notch
    (62.8, 46.3),(63.7, 46.6),(65.4, 46.1),
    (67.5, 46.1),(69.0, 47.8),(71.5, 47.3),
    // ── Florida ────────────────────────────────────────────────────────
    (73.0, 53.2),(74.4, 58.8),(74.4, 60.0),  // → Key West tip
    (77.2, 56.7),(76.5, 50.0),(75.8, 48.4),  // east coast ↑
    (74.9, 44.7),
    // ── Atlantic coast (north) ─────────────────────────────────────────
    (75.5, 41.6),(79.1, 37.5),(81.0, 36.7),
    (83.0, 35.0),(85.2, 33.6),               // Cape Hatteras bump
    (84.5, 29.6),(84.3, 29.1),(86.2, 26.5),
    (86.4, 25.0),(87.9, 20.8),(89.6, 20.6),
    (91.4, 19.4),
    // Cape Cod hook
    (93.0, 17.2),(94.7, 16.9),(93.6, 18.0),
    // New England
    (93.1, 16.3),(93.6, 15.7),(93.4, 14.5),
    (94.3, 13.1),(97.9, 11.4),(100.0, 10.5), // ← Eastport ME
    // ── Northern border (west) ─────────────────────────────────────────
    (92.9, 9.1), (89.1, 9.8), (87.6, 9.8),
    (83.3, 13.1),(79.1, 14.3),               // Lake Ontario / Niagara
    (72.7, 18.0),(69.1, 18.0),(64.3, 17.6),  // Lake Erie
    (63.9, 12.2),(63.4, 9.8),                // Lake Michigan
    (58.6, 5.9), (56.5, 5.4),               // Lake Superior
    (47.7, 0.0), (35.9, 0.0),               // 49th parallel
    (15.2, 0.0), (3.1, 0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Uniform scale to preserve geographic aspect ratio (100 × 60 units)
    final scale = math.min(w / 100.0, h / 60.0);
    final ox = (w - 100 * scale) / 2;
    final oy = (h - 60 * scale) / 2;

    Offset pt(double x, double y) =>
        Offset(ox + x * scale, oy + y * scale);

    final first = pt(_outline[0].$1, _outline[0].$2);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < _outline.length; i++) {
      final p = pt(_outline[i].$1, _outline[i].$2);
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    // Subtle interior fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(22)
        ..style = PaintingStyle.fill,
    );
    // Border stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_UsOutlinePainter old) => old.color != color;
}
