import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/simulation_exam_providers.dart';
import '../widgets/exam_result_content.dart';

/// Full-screen score + review shown right after an attempt is submitted.
/// Fetches the authoritative breakdown from `GET .../results` rather than
/// trusting the submit response alone, so this and the history result
/// sheet always render identically for the same attempt.
class ExamResultScreen extends ConsumerWidget {
  const ExamResultScreen({super.key, required this.attemptId});

  final int attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(examResultProvider(attemptId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(context, ref);
      },
      child: Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isDesktop || context.isTablet
                    ? 560
                    : double.infinity,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      context.sp(16),
                      context.sp(20),
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.t('exam.result.title'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.w800,
                              color: context.appTextPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _finish(context, ref),
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: resultAsync.when(
                      data: (result) => ListView(
                        padding: EdgeInsets.fromLTRB(
                          context.sp(20),
                          context.sp(8),
                          context.sp(20),
                          context.sp(16),
                        ),
                        children: [ExamResultContent(result: result)],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _ErrorView(
                        onRetry: () =>
                            ref.invalidate(examResultProvider(attemptId)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      0,
                      context.sp(20),
                      context.sp(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, context.sp(52)),
                        ),
                        onPressed: () => _finish(context, ref),
                        child: Text(context.t('exam.result.done')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Leaves the result screen and invalidates the history list so the
  /// simulation tab refetches it — otherwise the newly submitted attempt
  /// wouldn't show up since `examHistoryProvider` caches its last result.
  void _finish(BuildContext context, WidgetRef ref) {
    ref.invalidate(examHistoryProvider);
    Navigator.of(context).popUntil((route) => route.isFirst);
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
