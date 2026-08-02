import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../data/mock_exam_questions.dart';
import '../../domain/entities/exam_question.dart';

/// Snapshot of one simulation run: the generated question list, where the
/// user currently is, and every answer picked so far.
class ExamState {
  const ExamState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.submitted = false,
  });

  final List<ExamQuestion> questions;
  final int currentIndex;
  final Map<String, String> selectedAnswers;
  final bool submitted;

  ExamQuestion get currentQuestion => questions[currentIndex];
  String? get selectedOptionId => selectedAnswers[currentQuestion.id];
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == questions.length - 1;
  int get answeredCount => selectedAnswers.length;

  ExamState copyWith({
    int? currentIndex,
    Map<String, String>? selectedAnswers,
    bool? submitted,
  }) => ExamState(
    questions: questions,
    currentIndex: currentIndex ?? this.currentIndex,
    selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    submitted: submitted ?? this.submitted,
  );
}

/// Drives one simulation run. Free (unsubscribed) users may only view the
/// first [SubscriptionState.trialQuestionsTotal] questions — [next] reports
/// false once that quota is reached so the screen can route to the paywall
/// instead of advancing.
class ExamController extends Notifier<ExamState> {
  @override
  ExamState build() =>
      ExamState(questions: buildExamQuestions(AppConstants.examQuestionCount));

  void selectAnswer(String optionId) {
    final questionId = state.currentQuestion.id;
    state = state.copyWith(
      selectedAnswers: {...state.selectedAnswers, questionId: optionId},
    );
  }

  void previous() {
    if (state.isFirst) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Returns `true` when the move succeeded, `false` when a free-tier user
  /// hit their trial quota and must subscribe to keep going.
  bool next() {
    if (state.isLast) return true;
    final nextIndex = state.currentIndex + 1;
    final subscription = ref.read(subscriptionProvider);
    if (!subscription.isSubscribed &&
        nextIndex >= subscription.trialQuestionsTotal) {
      return false;
    }
    state = state.copyWith(currentIndex: nextIndex);
    ref.read(subscriptionProvider.notifier).recordTrialProgress(nextIndex + 1);
    return true;
  }

  void submit() => state = state.copyWith(submitted: true);

  /// Starts a fresh run, discarding all answers.
  void restart() => state = ExamState(
    questions: buildExamQuestions(AppConstants.examQuestionCount),
  );
}

final examControllerProvider = NotifierProvider<ExamController, ExamState>(
  ExamController.new,
);
