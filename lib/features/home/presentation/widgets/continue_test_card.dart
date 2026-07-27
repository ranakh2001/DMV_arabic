import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import 'circular_progress_ring.dart';

/// Glass card showing an in-progress simulation test with a ring badge for
/// answered/total questions and a "continue" link.
class ContinueTestCard extends StatelessWidget {
  const ContinueTestCard({
    super.key,
    required this.title,
    required this.answered,
    required this.total,
    required this.onTap,
  });

  final String title;
  final int answered;
  final int total;
  final VoidCallback onTap;

  /// `false` once the user hasn't answered anything yet — swaps the ring for
  /// a plain start icon and the "continue" label for a "start" one.
  bool get hasProgress => answered > 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: GlassContainer(
        radius: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('🇺🇸', style: TextStyle(fontSize: 16)),
                      SizedBox(width: context.sp(6)),
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: context.sp(15),
                            fontWeight: FontWeight.w700,
                            color: context.appTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(8)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t(
                          hasProgress ? 'home.continue_now' : 'home.start_now',
                        ),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w600,
                          color: context.appPrimary,
                        ),
                      ),
                      SizedBox(width: context.sp(4)),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: context.sp(15),
                        color: context.appPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            hasProgress
                ? CircularProgressRing(
                    value: total == 0 ? 0 : answered / total,
                    centerText: '$answered/$total',
                  )
                : Container(
                    width: context.sp(56),
                    height: context.sp(56),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appPrimary.withAlpha(30),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: context.appPrimary,
                      size: context.sp(26),
                    ),
                  ),

            // SizedBox(width: context.sp(14)),
          ],
        ),
      ),
    );
  }
}
