import '../../domain/entities/exam_submit_result.dart';

/// Nested `attempt` object on a `POST /exam-attempts/{attemptId}/submit`
/// response.
class ExamAttemptSummaryModel {
  const ExamAttemptSummaryModel({
    required this.id,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
  });

  final int id;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;

  factory ExamAttemptSummaryModel.fromJson(Map<String, dynamic> json) =>
      ExamAttemptSummaryModel(
        id: json['id'] as int,
        score: json['score'] as int? ?? 0,
        totalQuestions: json['total_questions'] as int? ?? 0,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
        passed: json['passed'] == true,
      );
}

/// Data model for the `data` object of
/// `POST /exam-attempts/{attemptId}/submit`.
class ExamSubmitModel {
  const ExamSubmitModel({
    required this.attempt,
    required this.timeTaken,
    required this.answeredQuestions,
    required this.unansweredQuestions,
    required this.passed,
    required this.passingScore,
  });

  final ExamAttemptSummaryModel attempt;
  final String timeTaken;
  final int answeredQuestions;
  final int unansweredQuestions;
  final bool passed;
  final int passingScore;

  factory ExamSubmitModel.fromJson(Map<String, dynamic> json) =>
      ExamSubmitModel(
        attempt: ExamAttemptSummaryModel.fromJson(
          json['attempt'] as Map<String, dynamic>? ?? const {},
        ),
        timeTaken: json['time_taken'] as String? ?? '00:00',
        answeredQuestions: json['answered_questions'] as int? ?? 0,
        unansweredQuestions: json['unanswered_questions'] as int? ?? 0,
        passed: json['passed'] == true,
        passingScore: json['passing_score'] as int? ?? 0,
      );

  ExamSubmitResult toEntity() => ExamSubmitResult(
    attemptId: attempt.id,
    score: attempt.score,
    totalQuestions: attempt.totalQuestions,
    correctAnswers: attempt.correctAnswers,
    incorrectAnswers: attempt.incorrectAnswers,
    passed: passed,
    passingScore: passingScore,
    answeredQuestions: answeredQuestions,
    unansweredQuestions: unansweredQuestions,
    timeTaken: timeTaken,
  );
}
