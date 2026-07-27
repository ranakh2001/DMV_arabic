import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../states/domain/entities/us_state.dart';
import '../../../states/presentation/widgets/state_picker_sheet.dart';
import 'onboarding_animated_pin.dart';
import 'onboarding_content_card.dart';
import 'painters/map_grid_painter.dart';
import 'painters/us_outline_painter.dart';

/// Onboarding slide 3: pick the user's DMV state on a stylized US map.
class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key, required this.selectedState, required this.onStateChanged});

  final UsState? selectedState;
  final ValueChanged<UsState?> onStateChanged;

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> with SingleTickerProviderStateMixin {
  late final AnimationController _pinsCtrl;

  static const _pinPositions = [
    (0.12, 0.20), // Washington
    (0.06, 0.44), // California
    (0.44, 0.12), // Minnesota
    (0.72, 0.22), // New York
    (0.66, 0.40), // Virginia
    (0.60, 0.62), // Georgia
    (0.27, 0.58), // Texas
  ];

  @override
  void initState() {
    super.initState();
    _pinsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _pinsCtrl.dispose();
    super.dispose();
  }

  void _showStatePicker(BuildContext context) {
    showStatePickerSheet(context, currentStateId: widget.selectedState?.id, onSelected: widget.onStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final accent = context.appPrimary;
    final isAr = context.isRtl;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.22),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 20),
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
                        Positioned.fill(child: CustomPaint(painter: MapGridPainter(color: context.appTextSecondary.withAlpha(8)))),
                        Positioned.fill(child: CustomPaint(painter: UsOutlinePainter(color: accent.withAlpha(55)))),
                        Positioned(
                          left: w * 0.16,
                          top: h * 0.35,
                          child: Container(
                            width: w * 0.58,
                            height: h * 0.50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [context.appSecondary.withAlpha(95), context.appSecondary.withAlpha(0)]),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            for (var i = 0; i < _pinPositions.length; i++)
                              OnboardingAnimatedPin(
                                x: _pinPositions[i].$1 * w,
                                y: _pinPositions[i].$2 * h,
                                delay: i / _pinPositions.length,
                                controller: _pinsCtrl,
                                color: accent,
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
          OnboardingContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('onboarding.slide3.title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Almarai', fontSize: 22, fontWeight: FontWeight.w700, color: context.appTextPrimary, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('onboarding.slide3.subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Almarai', fontSize: 15, color: context.appTextSecondary, height: 1.5),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _showStatePicker(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.selectedState != null ? accent : accent.withAlpha(80),
                        width: widget.selectedState != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_rounded, color: accent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.selectedState?.name(arabic: isAr) ?? context.t('onboarding.slide3.placeholder'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 15,
                              color: widget.selectedState != null ? context.appTextPrimary : context.appTextSecondary,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.t('onboarding.slide3.hint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appTextSecondary, height: 1.4),
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
