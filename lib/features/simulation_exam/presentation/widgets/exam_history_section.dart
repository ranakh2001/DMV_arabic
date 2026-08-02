import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../domain/entities/exam_history_entry.dart';
import '../providers/simulation_exam_providers.dart';
import 'exam_history_result_sheet.dart';

/// Lists the signed-in user's past simulation attempts (`GET
/// /exam-attempts/history`). Tapping a row opens [showExamHistoryResultSheet]
/// with that attempt's full score breakdown.
class ExamHistorySection extends ConsumerWidget {
  const ExamHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(examHistoryProvider);

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Container(
            padding: EdgeInsets.all(context.sp(16)),
            decoration: BoxDecoration(
              color: context.appGlassTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appGlassBorder),
            ),
            child: Text(
              context.t('exam.history_empty'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                color: context.appTextSecondary,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              _ExamHistoryTile(entry: entries[i]),
              if (i != entries.length - 1) SizedBox(height: context.sp(10)),
            ],
          ],
        );
      },
      loading: () => const SkeletonList(count: 2),
      error: (error, _) => Container(
        padding: EdgeInsets.all(context.sp(16)),
        decoration: BoxDecoration(
          color: context.appGlassTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appGlassBorder),
        ),
        child: Column(
          children: [
            Text(
              context.t('exam.history_error'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                color: context.appTextSecondary,
              ),
            ),
            SizedBox(height: context.sp(8)),
            TextButton(
              onPressed: () => ref.invalidate(examHistoryProvider),
              child: Text(context.t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamHistoryTile extends StatelessWidget {
  const _ExamHistoryTile({required this.entry});

  final ExamHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final statusColor = entry.passed ? context.appSuccess : context.appError;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showExamHistoryResultSheet(context, attemptId: entry.id),
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
              width: context.sp(40),
              height: context.sp(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withAlpha(32),
              ),
              child: Icon(
                entry.passed ? Icons.check_rounded : Icons.close_rounded,
                color: statusColor,
                size: context.sp(20),
              ),
            ),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.examTitleAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(13.5),
                      fontWeight: FontWeight.w700,
                      color: context.appTextPrimary,
                    ),
                  ),
                  SizedBox(height: context.sp(4)),
                  Text(
                    _formatDate(entry.startTime),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(11.5),
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(10),
                vertical: context.sp(6),
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(28),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${entry.correctAnswers}/${entry.totalQuestions}',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }
}
