import '../../domain/entities/exam_summary.dart';

/// Mirrors the exam object shape reused across `/simulation-exams`,
/// attempt-start, results, and history responses.
class ExamSummaryModel {
  const ExamSummaryModel({
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

  factory ExamSummaryModel.fromJson(Map<String, dynamic> json) =>
      ExamSummaryModel(
        id: json['id'] as int,
        titleAr: json['title_ar'] as String? ?? '',
        stateId: json['state_id'] as int,
        totalQuestions: json['total_questions'] as int? ?? 0,
        passingScore: json['passing_score'] as int? ?? 0,
      );

  ExamSummary toEntity() => ExamSummary(
    id: id,
    titleAr: titleAr,
    stateId: stateId,
    totalQuestions: totalQuestions,
    passingScore: passingScore,
  );
}
