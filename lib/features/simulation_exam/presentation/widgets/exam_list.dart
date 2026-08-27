import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
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
              if (i != exams.length - 1) SizedBox(height: context.sp(16)),
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
    return GlassContainer(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: context.appPrimary,
                size: context.sp(20),
              ),
              SizedBox(width: context.sp(8)),
              Expanded(
                child: Text(
                  exam.titleAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(16)),
          _ExamDetailRow(
            icon: Icons.help_outline_rounded,
            label: context.t('simulation.question_count_label'),
            value: context.ts('simulation.question_count_value', {
              'count': '${exam.totalQuestions}',
            }),
            valueColor: context.appTextPrimary,
          ),
          SizedBox(height: context.sp(12)),
          _ExamDetailRow(
            icon: Icons.check_circle_outline_rounded,
            label: context.t('simulation.min_pass_label'),
            value: context.ts('simulation.min_pass_value', {
              'count': '${exam.passingScore}',
            }),
            valueColor: context.appSuccess,
          ),
          SizedBox(height: context.sp(12)),
          _ExamDetailRow(
            icon: Icons.all_inclusive_rounded,
            label: context.t('simulation.time_label'),
            value: context.t('simulation.time_value'),
            valueColor: context.appSecondary,
          ),
          SizedBox(height: context.sp(16)),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(context.t('exam.picker.start')),
          ),
        ],
      ),
    );
  }
}

class _ExamDetailRow extends StatelessWidget {
  const _ExamDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: context.sp(16), color: context.appTextSecondary),
              SizedBox(width: context.sp(6)),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(14),
                    color: context.appTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.sp(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(12),
            vertical: context.sp(6),
          ),
          decoration: BoxDecoration(
            color: valueColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: valueColor.withAlpha(90)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
