import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';

/// Correct/incorrect result + explanation, shown once a question has been
/// graded. Shared by the Practice (free-trial) and Simulation exam screens
/// so both flows present feedback identically.
class AnswerFeedbackBanner extends StatelessWidget {
  const AnswerFeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.explanationAr,
  });

  final bool isCorrect;
  final String explanationAr;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? context.appSuccess : context.appError;
    return Container(
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: color,
                size: context.sp(20),
              ),
              SizedBox(width: context.sp(8)),
              Text(
                context.t(
                  isCorrect ? 'practice.correct' : 'practice.incorrect',
                ),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                  fontSize: context.sp(14),
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
          if (explanationAr.isNotEmpty) ...[
            SizedBox(height: context.sp(8)),
            Text(
              explanationAr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                color: context.appTextSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
