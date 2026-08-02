import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';

/// Bottom action row: Previous / Submit / Next. The physical layout is
/// pinned to left-to-right ([Previous] left, [Next] right) regardless of
/// the app's language, so the buttons don't swap sides when switching
/// between Arabic and English.
class ExamNavBar extends StatelessWidget {
  const ExamNavBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: canGoPrevious ? onPrevious : null,
              icon: Icon(Icons.arrow_back_rounded, size: context.sp(18)),
              label: Text(
                context.t('exam.previous'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: onSubmit,
              icon: Icon(Icons.done_all_rounded, size: context.sp(18)),
              label: Text(
                context.t('exam.submit'),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Deliberately below the app's usual 15pt floor: this is
                // compact button chrome (not body text), and the 3-button
                // row is tight enough that the normal size wraps.
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: canGoNext ? onNext : null,
              icon: Icon(Icons.arrow_forward_rounded, size: context.sp(18)),
              iconAlignment: IconAlignment.end,
              label: Text(context.t('exam.next'), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
