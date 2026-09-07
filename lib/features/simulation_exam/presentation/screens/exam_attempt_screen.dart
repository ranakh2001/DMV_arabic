import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/widgets/answer_feedback_banner.dart';
import '../../../exam/presentation/widgets/exam_nav_bar.dart';
import '../../../exam/presentation/widgets/exam_top_bar.dart';
import '../../../exam/presentation/widgets/option_letters.dart';
import '../../../exam/presentation/widgets/question_progress_bar.dart';
import '../../../practice/presentation/widgets/practice_option_tile.dart';
import '../../../practice/presentation/widgets/practice_question_media.dart';
import '../providers/exam_attempt_controller.dart';
import 'exam_result_screen.dart';

const _optionLetters = ['a', 'b', 'c', 'd'];

/// One live simulation attempt, one question per screen, backed by the
/// real exam-attempt API (start → answer-and-grade-per-pick → submit).
/// Each answer reveals correct/incorrect feedback immediately, same as
/// Practice mode.
class ExamAttemptScreen extends ConsumerWidget {
  const ExamAttemptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(examAttemptControllerProvider);
    final controller = ref.read(examAttemptControllerProvider.notifier);
    final isAr = context.l10n.locale.languageCode == 'ar';
    final stateName = ref.watch(prefsServiceProvider).selectedState ?? '';
    final question = attempt.currentQuestion;

    ref.listen(examAttemptControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    if (question == null) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) {
          controller.reset();
          Navigator.of(context).pop();
        }
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.sp(20),
                        context.sp(16),
                        context.sp(20),
                        context.sp(24),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () async {
                              final shouldExit = await _confirmExit(context);
                              if (shouldExit && context.mounted) {
                                controller.reset();
                                Navigator.of(context).pop();
                              }
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: context.appTextSecondary,
                            ),
                          ),
                        ),
                        ExamTopBar(
                          current: attempt.currentIndex + 1,
                          total: attempt.questions.length,
                          stateName: stateName,
                        ),
                        SizedBox(height: context.sp(16)),
                        GlassContainer(
                          radius: 20,
                          child: Column(
                            children: [
                              if (question.isImageQuestion &&
                                  question.imageFullUrl != null) ...[
                                PracticeQuestionMedia(
                                  imageUrl: question.imageFullUrl!,
                                ),
                                SizedBox(height: context.sp(18)),
                              ],
                              Text(
                                question.questionText(isAr),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: context.sp(15),
                                  fontWeight: FontWeight.w700,
                                  color: context.appTextPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.sp(16)),
                        if (attempt.status ==
                            ExamAttemptStatus.savingAnswer) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              minHeight: context.sp(4),
                            ),
                          ),
                          SizedBox(height: context.sp(12)),
                        ],
                        for (var i = 0; i < _optionLetters.length; i++) ...[
                          PracticeOptionTile(
                            letter: optionLetter(isAr, i),
                            text: question.optionText(
                              _optionLetters[i],
                              isAr: isAr,
                            ),
                            isSelected:
                                attempt.selectedOptionLetter ==
                                _optionLetters[i],
                            isCorrectAnswer:
                                question.correctAnswer == _optionLetters[i],
                            revealed: attempt.revealed,
                            locked: attempt.isBusy,
                            onTap: () =>
                                controller.selectAnswer(_optionLetters[i]),
                          ),
                          if (i != _optionLetters.length - 1)
                            SizedBox(height: context.sp(12)),
                        ],
                        if (attempt.revealed) ...[
                          SizedBox(height: context.sp(16)),
                          AnswerFeedbackBanner(
                            isCorrect: attempt.isCurrentCorrect!,
                            explanationAr: question.explanationAr,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      0,
                      context.sp(20),
                      context.sp(24),
                    ),
                    child: Column(
                      children: [
                        QuestionProgressBar(
                          total: attempt.questions.length,
                          currentIndex: attempt.currentIndex,
                          answeredIndexes: _answeredIndexes(attempt),
                          correctness: _correctnessByIndex(attempt),
                        ),
                        SizedBox(height: context.sp(20)),
                        ExamNavBar(
                          canGoPrevious: !attempt.isFirst && !attempt.isBusy,
                          canGoNext: !attempt.isLast && !attempt.isBusy,
                          onPrevious: controller.previous,
                          onNext: () => controller.next(),
                          onSubmit: attempt.isBusy
                              ? () {}
                              : () => _handleSubmit(context, ref),
                        ),
                      ],
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

  Set<int> _answeredIndexes(ExamAttemptState attempt) {
    final answered = <int>{};
    for (var i = 0; i < attempt.questions.length; i++) {
      if (attempt.selectedAnswers.containsKey(attempt.questions[i].id)) {
        answered.add(i);
      }
    }
    return answered;
  }

  Map<int, bool> _correctnessByIndex(ExamAttemptState attempt) {
    final correctness = <int, bool>{};
    for (var i = 0; i < attempt.questions.length; i++) {
      final isCorrect = attempt.answerCorrectness[attempt.questions[i].id];
      if (isCorrect != null) correctness[i] = isCorrect;
    }
    return correctness;
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.t('exam.submit_confirm_title')),
        content: Text(dialogContext.t('exam.submit_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.t('common.confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final attemptId = ref.read(examAttemptControllerProvider).attemptId;
    final result = await ref
        .read(examAttemptControllerProvider.notifier)
        .submit();
    if (!context.mounted || result == null || attemptId == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t('exam.submitted_message'))),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExamResultScreen(attemptId: attemptId),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.t('exam.exit_confirm_title')),
        content: Text(dialogContext.t('exam.exit_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.t('common.cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.appError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.t('exam.exit_confirm_action')),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
