import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../states/domain/entities/us_state.dart';
import 'onboarding_page_dots.dart';

/// Page dots + primary CTA + secondary link pinned to the bottom of the
/// onboarding [PageView].
class OnboardingBottomControls extends StatelessWidget {
  const OnboardingBottomControls({
    super.key,
    required this.currentPage,
    required this.selectedState,
    required this.onNext,
    required this.onSkip,
    required this.onLogin,
  });

  final int currentPage;
  final UsState? selectedState;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == 2;
    final canProceed = !isLastPage || selectedState != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingPageDots(current: currentPage, total: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: AnimatedOpacity(
                opacity: canProceed ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 250),
                child: ElevatedButton(
                  onPressed: canProceed ? onNext : null,
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
            if (isLastPage)
              GestureDetector(
                onTap: onLogin,
                child: Text(
                  context.t('onboarding.have_account'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    color: context.appTextSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: context.appTextSecondary,
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
                    color: context.appTextSecondary,
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
