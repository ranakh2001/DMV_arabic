/// One past attempt row from `GET /exam-attempts/history`.
class ExamHistoryEntry {
  const ExamHistoryEntry({
    required this.id,
    required this.examTitleAr,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
    required this.completionStatus,
    required this.startTime,
    this.endTime,
  });

  final int id;
  final String examTitleAr;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;

  /// e.g. `"completed"`.
  final String completionStatus;
  final DateTime startTime;
  final DateTime? endTime;
}
