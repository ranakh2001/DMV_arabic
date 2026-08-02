/// Server-acknowledged save + grading of one attempt answer via
/// `POST /exam-attempts/{attemptId}/answers`. [isCorrect] drives the
/// immediate per-question feedback in `ExamAttemptScreen`, the same way
/// Practice mode's `check-answer` does.
class ExamAnswerResult {
  const ExamAnswerResult({
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  final int attemptId;
  final int questionId;
  final String selectedAnswer;
  final bool isCorrect;
}
