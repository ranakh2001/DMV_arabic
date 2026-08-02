import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// One selectable answer row with immediate correct/incorrect feedback once
/// [revealed] is true. Originally Practice-only; also used by the live
/// Simulation exam attempt screen now that it grades each answer on
/// selection instead of withholding feedback until submit.
class PracticeOptionTile extends StatelessWidget {
  const PracticeOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.revealed,
    this.locked = false,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool revealed;

  /// True while the answer is being graded server-side — disables taps
  /// without yet applying the revealed correct/incorrect colors.
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    if (!revealed) {
      background = isSelected
          ? context.appPrimary.withAlpha(28)
          : context.appGlassTint;
      border = isSelected ? context.appPrimary : context.appGlassBorder;
    } else if (isCorrectAnswer) {
      background = context.appSuccess.withAlpha(40);
      border = context.appSuccess;
    } else if (isSelected) {
      background = context.appError.withAlpha(40);
      border = context.appError;
    } else {
      background = context.appGlassTint;
      border = context.appGlassBorder;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: (revealed || locked) ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(14),
          vertical: context.sp(14),
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: border,
            width: isSelected || (revealed && isCorrectAnswer) ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            _LetterBadge(
              letter: letter,
              highlighted: isSelected || (revealed && isCorrectAnswer),
              color: border,
            ),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Text(
                text,

                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                  height: 1.5,
                ),
              ),
            ),
            if (revealed && isCorrectAnswer)
              Icon(
                Icons.check_circle_rounded,
                color: context.appSuccess,
                size: context.sp(20),
              ),
            if (revealed && isSelected && !isCorrectAnswer)
              Icon(
                Icons.cancel_rounded,
                color: context.appError,
                size: context.sp(20),
              ),
          ],
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({
    required this.letter,
    required this.highlighted,
    required this.color,
  });

  final String letter;
  final bool highlighted;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(28),
      height: context.sp(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? color : Colors.transparent,
        border: Border.all(color: color),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(13),
          fontWeight: FontWeight.w700,
          color: highlighted ? Colors.white : context.appTextSecondary,
        ),
      ),
    );
  }
}
