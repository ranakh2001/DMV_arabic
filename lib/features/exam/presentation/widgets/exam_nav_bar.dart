import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';

/// Bottom action row: Previous / Submit / Next. Order is written in reading
/// order ([Previous, Submit, Next]) so Directionality mirrors it correctly
/// for both RTL and LTR without any conditional layout logic.
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final nextIcon = isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded;
    final previousIcon = isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded;

    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: canGoPrevious ? onPrevious : null,
            icon: Icon(previousIcon, size: context.sp(18)),
            label: Text(context.t('exam.previous'), textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
            onPressed: onSubmit,
            icon: Icon(Icons.done_all_rounded, size: context.sp(18)),
            label: Text(context.t('exam.submit'), textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
            onPressed: canGoNext ? onNext : null,
            icon: Icon(nextIcon, size: context.sp(18)),
            iconAlignment: IconAlignment.end,
            label: Text(context.t('exam.next'), textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
