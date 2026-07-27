import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated progress bar + version/copyright lines shown at the bottom of
/// the splash screen.
class SplashLoadingFooter extends StatelessWidget {
  const SplashLoadingFooter({super.key, required this.progress});

  /// 0.0-1.0, drives the bar fill width.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    final dimColor = context.appTextDisabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(color: dimColor, borderRadius: BorderRadius.circular(2)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AnimatedContainer(
                    duration: Duration.zero,
                    width: constraints.maxWidth * progress,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accent, context.appSecondary]),
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
            style: TextStyle(fontFamily: 'Almarai', fontSize: 13, fontWeight: FontWeight.w300, color: dimColor),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('splash.copyright'),
            style: TextStyle(fontFamily: 'Almarai', fontSize: 12, fontWeight: FontWeight.w300, color: dimColor.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}
