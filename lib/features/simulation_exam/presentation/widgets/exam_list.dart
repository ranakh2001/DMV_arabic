import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../domain/entities/exam_summary.dart';
import '../providers/simulation_exam_providers.dart';

/// Inline list of the published simulation exams for [stateId]
/// (`GET /simulation-exams`) — fetched as soon as this section builds (i.e.
/// as soon as the Simulation tab is shown, since [SimulationScreen] lives in
/// the always-mounted [IndexedStack] shell), instead of lazily behind a
/// bottom sheet. Tapping a card calls [onSelected] with that exam.
class ExamListSection extends ConsumerWidget {
  const ExamListSection({
    super.key,
    required this.stateId,
    required this.onSelected,
  });

  final int stateId;
  final ValueChanged<ExamSummary> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(simulationExamsProvider(stateId));

    return examsAsync.when(
      data: (exams) {
        if (exams.isEmpty) {
          return _ExamListMessage(text: context.t('exam.picker.empty'));
        }
        return Column(
          children: [
            for (var i = 0; i < exams.length; i++) ...[
              _ExamTile(exam: exams[i], onTap: () => onSelected(exams[i])),
              if (i != exams.length - 1) SizedBox(height: context.sp(10)),
            ],
          ],
        );
      },
      loading: () => const SkeletonList(count: 3),
      error: (error, _) => Column(
        children: [
          _ExamListMessage(text: context.t('exam.picker.error')),
          SizedBox(height: context.sp(8)),
          TextButton(
            onPressed: () => ref.invalidate(simulationExamsProvider(stateId)),
            child: Text(context.t('common.retry')),
          ),
        ],
      ),
    );
  }
}

class _ExamListMessage extends StatelessWidget {
  const _ExamListMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appGlassBorder),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(13),
          color: context.appTextSecondary,
        ),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({required this.exam, required this.onTap});

  final ExamSummary exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.sp(14)),
        decoration: BoxDecoration(
          color: context.appGlassTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appGlassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: context.sp(42),
              height: context.sp(42),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appPrimary.withAlpha(30),
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: context.appPrimary,
                size: context.sp(22),
              ),
            ),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.titleAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: context.appTextPrimary,
                    ),
                  ),
                  SizedBox(height: context.sp(4)),
                  Text(
                    context.ts('exam.picker.questions_count', {
                      'count': '${exam.totalQuestions}',
                    }),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(12),
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.sp(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(14),
                vertical: context.sp(8),
              ),
              decoration: BoxDecoration(
                color: context.appPrimary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                context.t('exam.picker.start'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(12.5),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
