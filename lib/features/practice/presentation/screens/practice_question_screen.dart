import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/widgets/answer_feedback_banner.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../exam/presentation/widgets/exam_top_bar.dart';
import '../../../exam/presentation/widgets/option_letters.dart';
import '../../../exam/presentation/widgets/question_progress_bar.dart';
import '../providers/free_trial_provider.dart';
import '../providers/practice_controller.dart';
import '../widgets/practice_option_tile.dart';
import '../widgets/practice_question_media.dart';
import 'trial_ended_screen.dart';

const _optionLetters = ['a', 'b', 'c', 'd'];

/// One free-trial Practice question per screen, with immediate per-answer
/// feedback (FR-24 to FR-30). This is the Practice/Learning experience —
/// deliberately independent of `exam/`'s Simulation flow, which must show no
/// feedback until manual submit.
class PracticeQuestionScreen extends ConsumerStatefulWidget {
  const PracticeQuestionScreen({super.key});

  @override
  ConsumerState<PracticeQuestionScreen> createState() =>
      _PracticeQuestionScreenState();
}

class _PracticeQuestionScreenState
    extends ConsumerState<PracticeQuestionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final stateId = ref.read(prefsServiceProvider).selectedStateId;
      if (stateId != null) {
        ref
            .read(practiceControllerProvider.notifier)
            .loadPool(stateId: stateId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final practice = ref.watch(practiceControllerProvider);
    final freeTrial = ref.watch(freeTrialProvider);
    final controller = ref.read(practiceControllerProvider.notifier);
    final stateId = ref.read(prefsServiceProvider).selectedStateId;

    // Load failures are rendered inline via `_ErrorView`; this only surfaces
    // a failed `check-answer` call (loadStatus stays `loaded` for those).
    ref.listen(practiceControllerProvider, (prev, next) {
      if (next.loadStatus == PracticeLoadStatus.loaded &&
          next.error != null &&
          prev?.error != next.error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: stateId == null
                      ? _ErrorView(message: 'الرجاء اختيار الولاية أولاً.')
                      : switch (practice.loadStatus) {
                          PracticeLoadStatus.initial ||
                          PracticeLoadStatus.loading =>
                            const _QuestionSkeleton(),
                          PracticeLoadStatus.failed => _ErrorView(
                            message: practice.error ?? 'تعذر تحميل الأسئلة.',
                          ),
                          PracticeLoadStatus.empty => _ErrorView(
                            message: context.t('practice.no_questions'),
                          ),
                          PracticeLoadStatus.loaded => _QuestionView(
                            practice: practice,
                            freeTrialTotal: freeTrial.max,
                            stateName:
                                ref.watch(prefsServiceProvider).selectedState ??
                                '',
                            onSelect: controller.selectAnswer,
                            onNext: () => _handleNext(context, controller),
                            onPrevious: controller.previous,
                          ),
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext(BuildContext context, PracticeController controller) {
    final moved = controller.next();
    if (!moved) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const TrialEndedScreen()),
      );
    }
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.practice,
    required this.freeTrialTotal,
    required this.stateName,
    required this.onSelect,
    required this.onNext,
    required this.onPrevious,
  });

  final PracticeState practice;
  final int freeTrialTotal;
  final String stateName;
  final void Function(String letter) onSelect;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final question = practice.currentQuestion!;
    final currentIndex = practice.poolIndex.clamp(0, freeTrialTotal - 1);
    final isAr = context.l10n.locale.languageCode == 'ar';

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.sp(20),
        context.sp(16),
        context.sp(20),
        context.sp(24),
      ),
      children: [
        ExamTopBar(
          current: currentIndex + 1,
          total: freeTrialTotal,
          stateName: stateName,
        ),
        SizedBox(height: context.sp(16)),
        GlassContainer(
          radius: 20,
          child: Column(
            children: [
              if (question.isImageQuestion &&
                  question.imageFullUrl != null) ...[
                PracticeQuestionMedia(imageUrl: question.imageFullUrl!),
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
        if (practice.checking) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(minHeight: context.sp(4)),
          ),
          SizedBox(height: context.sp(12)),
        ],
        for (var i = 0; i < _optionLetters.length; i++) ...[
          PracticeOptionTile(
            letter: optionLetter(isAr, i),
            text: question.optionText(_optionLetters[i], isAr: isAr),
            isSelected: practice.selectedAnswer == _optionLetters[i],
            isCorrectAnswer:
                (practice.checkResult?.correctAnswer ??
                    question.correctAnswer) ==
                _optionLetters[i],
            revealed: practice.revealed,
            locked: practice.checking,
            onTap: () => onSelect(_optionLetters[i]),
          ),
          if (i != _optionLetters.length - 1) SizedBox(height: context.sp(12)),
        ],
        if (practice.revealed) ...[
          SizedBox(height: context.sp(16)),
          AnswerFeedbackBanner(
            isCorrect: practice.isCorrect,
            explanationAr:
                practice.checkResult?.explanationAr ?? question.explanationAr,
          ),
        ],
        SizedBox(height: context.sp(20)),
        QuestionProgressBar(
          total: freeTrialTotal,
          currentIndex: currentIndex,
          answeredIndexes: {
            for (var i = 0; i < currentIndex; i++) i,
            if (practice.revealed) currentIndex,
          },
          correctness: practice.revealed
              ? {currentIndex: practice.isCorrect}
              : const {},
        ),
        if (currentIndex > 0 || practice.revealed) ...[
          SizedBox(height: context.sp(20)),
          Row(
            children: [
              if (currentIndex > 0)
                Expanded(
                  child: SizedBox(
                    height: context.sp(52),
                    child: OutlinedButton(
                      onPressed: onPrevious,
                      child: Text(context.t('practice.previous')),
                    ),
                  ),
                ),
              if (currentIndex > 0 && practice.revealed)
                SizedBox(width: context.sp(12)),
              if (practice.revealed)
                Expanded(
                  child: SizedBox(
                    height: context.sp(52),
                    child: ElevatedButton(
                      onPressed: onNext,
                      child: Text(context.t('practice.next')),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Shown while the pool loads — mirrors [_QuestionView]'s shape (top bar,
/// question card, four option rows) so the layout doesn't jump once data
/// arrives.
class _QuestionSkeleton extends StatelessWidget {
  const _QuestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.sp(20),
        context.sp(16),
        context.sp(20),
        context.sp(24),
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SkeletonCard(height: 24),
        SizedBox(height: context.sp(16)),
        const SkeletonCard(height: 110),
        SizedBox(height: context.sp(16)),
        const SkeletonList(count: 4),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.sp(24)),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(14),
            color: context.appTextSecondary,
          ),
        ),
      ),
    );
  }
}
