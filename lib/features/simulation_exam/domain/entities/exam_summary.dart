/// A simulation exam configured for a state, as listed by
/// `GET /simulation-exams` and echoed back inside attempt/result payloads.
class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.titleAr,
    required this.stateId,
    required this.totalQuestions,
    required this.passingScore,
  });

  final int id;
  final String titleAr;
  final int stateId;
  final int totalQuestions;
  final int passingScore;
}
