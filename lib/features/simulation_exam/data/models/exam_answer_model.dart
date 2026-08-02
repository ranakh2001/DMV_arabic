import '../../domain/entities/exam_answer_result.dart';

/// Data model for the `data` object of
/// `POST /exam-attempts/{attemptId}/answers`.
class ExamAnswerModel {
  const ExamAnswerModel({
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  final int attemptId;
  final int questionId;
  final String selectedAnswer;
  final bool isCorrect;

  factory ExamAnswerModel.fromJson(Map<String, dynamic> json) =>
      ExamAnswerModel(
        attemptId: json['attempt_id'] as int,
        questionId: json['question_id'] as int,
        selectedAnswer: json['selected_answer'] as String? ?? '',
        isCorrect: json['is_correct'] == true || json['is_correct'] == 1,
      );

  ExamAnswerResult toEntity() => ExamAnswerResult(
    attemptId: attemptId,
    questionId: questionId,
    selectedAnswer: selectedAnswer,
    isCorrect: isCorrect,
  );
}
