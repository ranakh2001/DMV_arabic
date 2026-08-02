/// Server-authoritative result of grading one answer via
/// `POST /questions/{id}/check-answer`. This is also how the free-trial
/// quota is tracked — the client no longer counts locally, it mirrors
/// whatever this endpoint reports.
class AnswerCheckResult {
  const AnswerCheckResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanationAr,
    required this.hasActiveSubscription,
    required this.upgradeRequired,
    this.freeQuestionsUsed,
    this.freeQuestionsLimit,
    this.remainingFreeQuestions,
  });

  final int questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String explanationAr;

  final bool hasActiveSubscription;
  final bool upgradeRequired;

  /// Null when [hasActiveSubscription] is true (quota doesn't apply).
  final int? freeQuestionsUsed;
  final int? freeQuestionsLimit;
  final int? remainingFreeQuestions;
}
