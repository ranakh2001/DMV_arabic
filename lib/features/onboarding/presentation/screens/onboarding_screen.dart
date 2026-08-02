import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../states/domain/entities/us_state.dart';
import '../../providers/onboarding_provider.dart';
import '../widgets/onboarding_bottom_controls.dart';
import '../widgets/onboarding_page1.dart';
import '../widgets/onboarding_page2.dart';
import '../widgets/onboarding_page3.dart';
import '../widgets/onboarding_starfield.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  UsState? _selectedState;

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
      final isAr = context.isRtl;
      await ref
          .read(prefsServiceProvider)
          .setSelectedState(_selectedState!.name(arabic: isAr));
      await ref
          .read(prefsServiceProvider)
          .setSelectedStateId(_selectedState!.id);
    }
    await ref.read(onboardingDoneProvider.notifier).complete();
  }

  Future<void> _goToLogin() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.appSurface, context.appBackground],
              ),
            ),
          ),
          const Positioned.fill(child: OnboardingStarfield()),
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              const OnboardingPage1(),
              const OnboardingPage2(),
              OnboardingPage3(
                selectedState: _selectedState,
                onStateChanged: (s) => setState(() => _selectedState = s),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OnboardingBottomControls(
              currentPage: _currentPage,
              selectedState: _selectedState,
              onNext: _goNext,
              onSkip: _skip,
              onLogin: _goToLogin,
            ),
          ),
        ],
      ),
    );
  }
}
