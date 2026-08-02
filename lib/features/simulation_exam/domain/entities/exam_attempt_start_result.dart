import '../../../questions/domain/entities/question.dart';
import 'exam_summary.dart';

/// Result of `POST /simulation-exams/{id}/start` — a fresh attempt id plus
/// the exam metadata and the full question set to run through.
///
/// The question payload returned here has the exact same shape as
/// `GET /questions`, so it is parsed with the shared [Question] entity
/// instead of duplicating a near-identical model.
class ExamAttemptStartResult {
  const ExamAttemptStartResult({
    required this.attemptId,
    required this.exam,
    required this.questions,
  });

  final int attemptId;
  final ExamSummary exam;
  final List<Question> questions;
}
