import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../subscription/presentation/screens/subscription_plans_screen.dart';
import '../providers/exam_controller.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/exam_nav_bar.dart';
import '../widgets/exam_top_bar.dart';
import '../widgets/option_letters.dart';
import '../widgets/question_media_card.dart';
import '../widgets/question_progress_bar.dart';

/// One simulation run, one question per screen. Free (unsubscribed) users
/// are routed to the paywall once [ExamController.next] reports their trial
/// quota is exhausted.
class ExamQuestionScreen extends ConsumerWidget {
  const ExamQuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exam = ref.watch(examControllerProvider);
    final controller = ref.read(examControllerProvider.notifier);
    final isAr = context.l10n.locale.languageCode == 'ar';
    final stateName = ref.watch(prefsServiceProvider).selectedState ?? 'كاليفورنيا';
    final question = exam.currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 560 : double.infinity),
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(16), context.sp(20), context.sp(24)),
                children: [
                  ExamTopBar(current: exam.currentIndex + 1, total: exam.questions.length, stateName: stateName),
                  SizedBox(height: context.sp(16)),
                  GlassContainer(
                    radius: 20,
                    child: Column(
                      children: [
                        QuestionMediaCard(icon: question.mediaIcon),
                        SizedBox(height: context.sp(18)),
                        Text(
                          question.prompt(isAr),
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
                  for (var i = 0; i < question.options.length; i++) ...[
                    Builder(builder: (context) {
                      final option = question.options[i];
                      final label = option.label(isAr);
                      return AnswerOptionTile(
                        letter: optionLetter(isAr, i),
                        text: label.isEmpty ? null : label,
                        icon: option.icon,
                        selected: exam.selectedOptionId == option.id,
                        onTap: () => controller.selectAnswer(option.id),
                      );
                    }),
                    if (i != question.options.length - 1) SizedBox(height: context.sp(12)),
                  ],
                  SizedBox(height: context.sp(20)),
                  QuestionProgressBar(
                    total: exam.questions.length,
                    currentIndex: exam.currentIndex,
                    answeredIndexes: _answeredIndexes(exam),
                  ),
                  SizedBox(height: context.sp(20)),
                  ExamNavBar(
                    canGoPrevious: !exam.isFirst,
                    canGoNext: !exam.isLast,
                    onPrevious: controller.previous,
                    onNext: () => _handleNext(context, controller),
                    onSubmit: () => _handleSubmit(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Set<int> _answeredIndexes(ExamState exam) {
    final answered = <int>{};
    for (var i = 0; i < exam.questions.length; i++) {
      if (exam.selectedAnswers.containsKey(exam.questions[i].id)) answered.add(i);
    }
    return answered;
  }

  void _handleNext(BuildContext context, ExamController controller) {
    final moved = controller.next();
    if (!moved) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubscriptionPlansScreen()));
    }
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
    if (confirmed == true && context.mounted) {
      ref.read(examControllerProvider.notifier).submit();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('exam.submitted_message'))));
    }
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
            style: FilledButton.styleFrom(backgroundColor: dialogContext.appError),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.t('exam.exit_confirm_action')),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
