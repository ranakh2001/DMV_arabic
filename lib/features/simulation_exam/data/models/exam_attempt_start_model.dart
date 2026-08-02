import '../../../questions/data/models/question_model.dart';
import '../../domain/entities/exam_attempt_start_result.dart';
import 'exam_summary_model.dart';

/// Data model for the `data` object of `POST /simulation-exams/{id}/start`.
class ExamAttemptStartModel {
  const ExamAttemptStartModel({
    required this.attemptId,
    required this.exam,
    required this.questions,
  });

  final int attemptId;
  final ExamSummaryModel exam;
  final List<QuestionModel> questions;

  factory ExamAttemptStartModel.fromJson(Map<String, dynamic> json) =>
      ExamAttemptStartModel(
        attemptId: json['attempt_id'] as int,
        exam: ExamSummaryModel.fromJson(
          json['exam'] as Map<String, dynamic>? ?? const {},
        ),
        questions: (json['questions'] as List<dynamic>? ?? [])
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  ExamAttemptStartResult toEntity() => ExamAttemptStartResult(
    attemptId: attemptId,
    exam: exam.toEntity(),
    questions: questions.map((q) => q.toEntity()).toList(),
  );
}
