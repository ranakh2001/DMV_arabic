/// Result of `POST /exam-attempts/{attemptId}/submit` — the final grading
/// summary for one attempt.
class ExamSubmitResult {
  const ExamSubmitResult({
    required this.attemptId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
    required this.passingScore,
    required this.answeredQuestions,
    required this.unansweredQuestions,
    required this.timeTaken,
  });

  final int attemptId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;
  final int passingScore;
  final int answeredQuestions;
  final int unansweredQuestions;

  /// Formatted `mm:ss` duration, as returned by the API.
  final String timeTaken;
}
