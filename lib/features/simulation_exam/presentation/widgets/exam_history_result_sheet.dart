import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass_effect_theme.dart';
import '../providers/simulation_exam_providers.dart';
import 'exam_result_content.dart';

/// Opens a modal bottom sheet with the full score + review for one past
/// attempt (`GET /exam-attempts/{attemptId}/results`), used when the user
/// taps a row in the Simulation tab's attempt history.
Future<void> showExamHistoryResultSheet(
  BuildContext context, {
  required int attemptId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExamHistoryResultSheet(attemptId: attemptId),
  );
}

class ExamHistoryResultSheet extends ConsumerWidget {
  const ExamHistoryResultSheet({super.key, required this.attemptId});

  final int attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = context.appPrimary;
    final resultAsync = ref.watch(examResultProvider(attemptId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        final glassTheme = Theme.of(context).extension<GlassEffectTheme>()!;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: glassTheme.blur,
              sigmaY: glassTheme.blur,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.appSurface.withAlpha(235),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: accent.withAlpha(60)),
              ),
              child: Column(
                children: [
                  SizedBox(height: context.sp(12)),
                  Container(
                    width: context.sp(40),
                    height: context.sp(4),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(120),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: context.sp(16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.t('exam.result.title'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w700,
                              color: context.appTextPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.appTextSecondary,
                            size: context.sp(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: context.appGlassBorder, height: 1),
                  Expanded(
                    child: resultAsync.when(
                      data: (result) => ListView(
                        controller: scrollCtrl,
                        padding: EdgeInsets.fromLTRB(
                          context.sp(20),
                          context.sp(16),
                          context.sp(20),
                          context.sp(24),
                        ),
                        children: [ExamResultContent(result: result)],
                      ),
                      loading: () => Center(
                        child: CircularProgressIndicator(color: accent),
                      ),
                      error: (error, _) => _ErrorView(
                        onRetry: () =>
                            ref.invalidate(examResultProvider(attemptId)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.sp(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t('exam.result.error'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                color: context.appTextSecondary,
              ),
            ),
            SizedBox(height: context.sp(12)),
            TextButton(
              onPressed: onRetry,
              child: Text(context.t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}
