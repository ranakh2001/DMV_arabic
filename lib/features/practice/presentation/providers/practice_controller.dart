import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_feedback_service.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../questions/domain/entities/answer_check_result.dart';
import '../../../questions/domain/entities/question.dart';
import '../../../questions/presentation/providers/questions_providers.dart';
import 'free_trial_provider.dart';

enum PracticeLoadStatus { initial, loading, loaded, failed }

/// One Practice-mode session: the fetched question pool for the user's
/// state, and where in that pool the free trial currently is.
///
/// This is the Practice/Learning experience (immediate per-answer feedback
/// via `check-answer`) — the live Simulation exam attempt now grades each
/// answer the same way (see `ExamAttemptController`), but keeps its own
/// state/controller since it's driven by a different API flow (attempt
/// start/answer/submit vs. a plain question pool).
class PracticeState {
  const PracticeState({
    this.loadStatus = PracticeLoadStatus.initial,
    this.pool = const [],
    this.poolIndex = 0,
    this.selectedAnswer,
    this.checking = false,
    this.revealed = false,
    this.checkResult,
    this.error,
  });

  final PracticeLoadStatus loadStatus;
  final List<Question> pool;
  final int poolIndex;
  final String? selectedAnswer;

  /// True while `check-answer` is in flight for the current selection.
  final bool checking;
  final bool revealed;

  /// Server-authoritative grading for the revealed answer — correctness,
  /// the correct letter, and the explanation all come from here rather than
  /// the question object once an answer has been checked.
  final AnswerCheckResult? checkResult;
  final String? error;

  /// The pool is assumed to be returned in a stable order per state, so
  /// `pool[poolIndex]` deterministically maps to "the Nth free-trial
  /// question" across app restarts (no per-question progress is persisted,
  /// only the count — see `FreeTrialController`).
  Question? get currentQuestion =>
      pool.isEmpty ? null : pool[poolIndex % pool.length];

  bool get isCorrect => checkResult?.isCorrect ?? false;

  PracticeState copyWith({
    PracticeLoadStatus? loadStatus,
    List<Question>? pool,
    int? poolIndex,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? checking,
    bool? revealed,
    AnswerCheckResult? checkResult,
    bool clearCheckResult = false,
    String? error,
    bool clearError = false,
  }) => PracticeState(
    loadStatus: loadStatus ?? this.loadStatus,
    pool: pool ?? this.pool,
    poolIndex: poolIndex ?? this.poolIndex,
    selectedAnswer: clearSelectedAnswer
        ? null
        : (selectedAnswer ?? this.selectedAnswer),
    checking: checking ?? this.checking,
    revealed: revealed ?? this.revealed,
    checkResult: clearCheckResult ? null : (checkResult ?? this.checkResult),
    error: clearError ? null : (error ?? this.error),
  );
}

class PracticeController extends Notifier<PracticeState> {
  @override
  PracticeState build() => const PracticeState();

  Future<void> loadPool({required int stateId}) async {
    state = state.copyWith(loadStatus: PracticeLoadStatus.loading);
    final result = await ref
        .read(getQuestionsUsecaseProvider)
        .call(stateId: stateId);
    result.fold(
      onSuccess: (questions) => state = PracticeState(
        loadStatus: PracticeLoadStatus.loaded,
        pool: questions,
        poolIndex: ref.read(freeTrialProvider).used,
      ),
      onFailure: (failure) => state = state.copyWith(
        loadStatus: PracticeLoadStatus.failed,
        error: failure.messageAr,
      ),
    );
  }

  /// Grades [letter] server-side via `check-answer`, reveals the result, and
  /// syncs the free-trial quota from that same response. Ignored once an
  /// answer for this question is already revealed/checking.
  Future<void> selectAnswer(String letter) async {
    final question = state.currentQuestion;
    if (state.revealed || state.checking || question == null) return;

    state = state.copyWith(
      selectedAnswer: letter,
      checking: true,
      clearCheckResult: true,
      clearError: true,
    );
    final result = await ref
        .read(checkAnswerUsecaseProvider)
        .call(questionId: question.id, selectedAnswer: letter);

    AnswerCheckResult? check;
    result.fold(
      onSuccess: (value) {
        check = value;
        state = state.copyWith(
          checking: false,
          revealed: true,
          checkResult: value,
        );
      },
      onFailure: (failure) => state = state.copyWith(
        checking: false,
        clearSelectedAnswer: true,
        error: failure.messageAr,
      ),
    );

    if (check != null) {
      await ref.read(freeTrialProvider.notifier).syncFromCheckAnswer(check!);
      final audio = ref.read(audioFeedbackServiceProvider);
      final isEnglish = ref.read(localeProvider).languageCode == 'en';
      unawaited(
        check!.isCorrect
            ? audio.playCorrectAnswerSound(isEnglish: isEnglish)
            : audio.playWrongAnswerSound(isEnglish: isEnglish),
      );
    }
  }

  /// Advances to the next pool question. Returns `false` when the free
  /// quota is already exhausted, so the screen can route to the trial-ended
  /// paywall instead of advancing.
  bool next() {
    if (ref.read(freeTrialProvider).isExhausted) return false;
    state = state.copyWith(
      poolIndex: state.poolIndex + 1,
      clearSelectedAnswer: true,
      revealed: false,
      clearCheckResult: true,
    );
    return true;
  }

  /// Steps back to the previous pool question, clearing any per-question
  /// answer state so it's shown fresh. No-op at the first question.
  void previous() {
    if (state.poolIndex <= 0) return;
    state = state.copyWith(
      poolIndex: state.poolIndex - 1,
      clearSelectedAnswer: true,
      revealed: false,
      clearCheckResult: true,
    );
  }
}

final practiceControllerProvider =
    NotifierProvider<PracticeController, PracticeState>(PracticeController.new);
