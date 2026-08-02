import 'exam_summary.dart';

/// One graded question inside an attempt's results, as returned by
/// `GET /exam-attempts/{attemptId}/results`.
class ExamResultAnswer {
  const ExamResultAnswer({
    required this.questionId,
    required this.questionTextAr,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanationAr,
    this.selectedAnswer,
    this.imageFullUrl,
  });

  final int questionId;
  final String questionTextAr;

  /// Null when the question was left unanswered.
  final String? selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanationAr;
  final String? imageFullUrl;
}

/// Full breakdown for one exam attempt — score summary plus a per-question
/// review — as returned by `GET /exam-attempts/{attemptId}/results`.
class ExamResultDetail {
  const ExamResultDetail({
    required this.attemptId,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
    required this.timeTaken,
    required this.exam,
    required this.answers,
  });

  final int attemptId;
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;
  final String timeTaken;
  final ExamSummary exam;
  final List<ExamResultAnswer> answers;
}
