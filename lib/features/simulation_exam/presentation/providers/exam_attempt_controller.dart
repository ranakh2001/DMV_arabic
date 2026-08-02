import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_feedback_service.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../questions/domain/entities/question.dart';
import '../../domain/entities/exam_submit_result.dart';
import '../../domain/entities/exam_summary.dart';
import 'simulation_exam_providers.dart';

enum ExamAttemptStatus {
  idle,
  starting,
  inProgress,
  savingAnswer,
  submitting,
  submitted,
  failed,
}

/// Snapshot of one live, API-backed simulation run: the started attempt,
/// its question set, where the user currently is, and every answer picked
/// so far. Each answer is graded immediately on selection (mirrors Practice
/// mode's immediate feedback) via [ExamAttemptController.selectAnswer].
class ExamAttemptState {
  const ExamAttemptState({
    this.status = ExamAttemptStatus.idle,
    this.attemptId,
    this.exam,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.answerCorrectness = const {},
    this.submitResult,
    this.error,
  });

  final ExamAttemptStatus status;
  final int? attemptId;
  final ExamSummary? exam;
  final List<Question> questions;
  final int currentIndex;

  /// Keyed by question id.
  final Map<int, String> selectedAnswers;

  /// Keyed by question id — populated once that question's answer has been
  /// graded server-side. Presence in this map is what drives `revealed`.
  final Map<int, bool> answerCorrectness;
  final ExamSubmitResult? submitResult;
  final String? error;

  Question? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];
  String? get selectedOptionLetter {
    final question = currentQuestion;
    return question == null ? null : selectedAnswers[question.id];
  }

  /// Whether the current question's answer has already been graded and
  /// should show its correct/incorrect coloring.
  bool get revealed {
    final question = currentQuestion;
    return question != null && answerCorrectness.containsKey(question.id);
  }

  bool? get isCurrentCorrect {
    final question = currentQuestion;
    return question == null ? null : answerCorrectness[question.id];
  }

  bool get isFirst => currentIndex == 0;
  bool get isLast => questions.isEmpty || currentIndex == questions.length - 1;
  int get answeredCount => selectedAnswers.length;
  bool get isBusy =>
      status == ExamAttemptStatus.savingAnswer ||
      status == ExamAttemptStatus.submitting;

  ExamAttemptState copyWith({
    ExamAttemptStatus? status,
    int? attemptId,
    ExamSummary? exam,
    List<Question>? questions,
    int? currentIndex,
    Map<int, String>? selectedAnswers,
    Map<int, bool>? answerCorrectness,
    ExamSubmitResult? submitResult,
    String? error,
    bool clearError = false,
  }) => ExamAttemptState(
    status: status ?? this.status,
    attemptId: attemptId ?? this.attemptId,
    exam: exam ?? this.exam,
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    answerCorrectness: answerCorrectness ?? this.answerCorrectness,
    submitResult: submitResult ?? this.submitResult,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Drives one live simulation attempt end-to-end: start → per-question
/// answer saving and grading (fired immediately on selection, with a retry
/// before Next/Submit if that save failed) → submit → server-graded summary.
class ExamAttemptController extends Notifier<ExamAttemptState> {
  @override
  ExamAttemptState build() => const ExamAttemptState();

  Future<bool> start({required int examId}) async {
    state = const ExamAttemptState(status: ExamAttemptStatus.starting);
    final result = await ref
        .read(startSimulationExamUsecaseProvider)
        .call(examId: examId);
    return result.fold(
      onSuccess: (data) {
        state = ExamAttemptState(
          status: ExamAttemptStatus.inProgress,
          attemptId: data.attemptId,
          exam: data.exam,
          questions: data.questions,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: ExamAttemptStatus.failed,
          error: failure.messageAr,
        );
        return false;
      },
    );
  }

  /// Picks [letter] for the current question and grades it immediately via
  /// the answer-save endpoint, revealing correct/incorrect feedback the same
  /// way Practice mode does. Ignored once the question is already
  /// revealed/graded, or while another save is in flight.
  Future<void> selectAnswer(String letter) async {
    final question = state.currentQuestion;
    if (question == null || state.isBusy || state.attemptId == null) return;
    if (state.answerCorrectness.containsKey(question.id)) return;

    state = state.copyWith(
      selectedAnswers: {...state.selectedAnswers, question.id: letter},
      status: ExamAttemptStatus.savingAnswer,
      clearError: true,
    );
    final result = await ref
        .read(answerExamQuestionUsecaseProvider)
        .call(
          attemptId: state.attemptId!,
          questionId: question.id,
          selectedAnswer: letter,
        );
    result.fold(
      onSuccess: (value) {
        state = state.copyWith(
          status: ExamAttemptStatus.inProgress,
          answerCorrectness: {
            ...state.answerCorrectness,
            question.id: value.isCorrect,
          },
        );
        final audio = ref.read(audioFeedbackServiceProvider);
        final isEnglish = ref.read(localeProvider).languageCode == 'en';
        unawaited(
          value.isCorrect
              ? audio.playCorrectAnswerSound(isEnglish: isEnglish)
              : audio.playWrongAnswerSound(isEnglish: isEnglish),
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: ExamAttemptStatus.inProgress,
          error: failure.messageAr,
        );
      },
    );
  }

  void previous() {
    if (state.isFirst || state.isBusy) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Retries saving+grading the active question's answer if [selectAnswer]'s
  /// own call for it failed earlier (so it's still missing from
  /// [ExamAttemptState.answerCorrectness]). No-ops once already graded, or
  /// when nothing is selected — safe to call unconditionally before
  /// advancing/submitting.
  Future<bool> _saveCurrentAnswer() async {
    final question = state.currentQuestion;
    final letter = question == null ? null : state.selectedAnswers[question.id];
    if (question == null || letter == null || state.attemptId == null)
      return true;
    if (state.answerCorrectness.containsKey(question.id)) return true;

    state = state.copyWith(status: ExamAttemptStatus.savingAnswer);
    final result = await ref
        .read(answerExamQuestionUsecaseProvider)
        .call(
          attemptId: state.attemptId!,
          questionId: question.id,
          selectedAnswer: letter,
        );
    return result.fold(
      onSuccess: (value) {
        state = state.copyWith(
          status: ExamAttemptStatus.inProgress,
          answerCorrectness: {
            ...state.answerCorrectness,
            question.id: value.isCorrect,
          },
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: ExamAttemptStatus.inProgress,
          error: failure.messageAr,
        );
        return false;
      },
    );
  }

  /// Saves the current answer (if one is selected) then advances. Returns
  /// `false` when the save failed, so the screen can surface the error
  /// instead of moving on.
  Future<bool> next() async {
    if (state.isLast || state.isBusy) return false;
    final saved = await _saveCurrentAnswer();
    if (!saved) return false;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    return true;
  }

  /// Saves the current answer (if any) then submits the whole attempt for
  /// grading. Returns the summary on success, or `null` on failure (with
  /// [ExamAttemptState.error] set).
  Future<ExamSubmitResult?> submit() async {
    if (state.isBusy || state.attemptId == null) return null;
    await _saveCurrentAnswer();

    state = state.copyWith(status: ExamAttemptStatus.submitting);
    final result = await ref
        .read(submitExamUsecaseProvider)
        .call(attemptId: state.attemptId!);
    return result.fold(
      onSuccess: (value) {
        state = state.copyWith(
          status: ExamAttemptStatus.submitted,
          submitResult: value,
        );
        return value;
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: ExamAttemptStatus.inProgress,
          error: failure.messageAr,
        );
        return null;
      },
    );
  }

  /// Clears the run so a fresh [start] can begin (e.g. leaving the screen).
  void reset() => state = const ExamAttemptState();
}

final examAttemptControllerProvider =
    NotifierProvider<ExamAttemptController, ExamAttemptState>(
      ExamAttemptController.new,
    );
