import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/exam_result_detail.dart';
import 'exam_summary_model.dart';

/// Nested `attempt` object on a `GET /exam-attempts/{attemptId}/results`
/// response.
class ExamResultAttemptModel {
  const ExamResultAttemptModel({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
    required this.timeTaken,
  });

  final int id;
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;
  final String timeTaken;

  factory ExamResultAttemptModel.fromJson(Map<String, dynamic> json) =>
      ExamResultAttemptModel(
        id: json['id'] as int,
        score: json['score'] as int? ?? 0,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
        passed: json['passed'] == true,
        timeTaken: json['time_taken'] as String? ?? '00:00',
      );
}

/// One entry in the `answers` array of a results response.
class ExamResultAnswerModel {
  const ExamResultAnswerModel({
    required this.questionId,
    required this.questionTextAr,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanationAr,
    this.selectedAnswer,
    this.imageUrl,
  });

  final int questionId;
  final String questionTextAr;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanationAr;
  final String? imageUrl;

  factory ExamResultAnswerModel.fromJson(Map<String, dynamic> json) =>
      ExamResultAnswerModel(
        questionId: json['question_id'] as int,
        questionTextAr: json['question_text_ar'] as String? ?? '',
        selectedAnswer: json['selected_answer'] as String?,
        correctAnswer: json['correct_answer'] as String? ?? '',
        isCorrect: json['is_correct'] == true || json['is_correct'] == 1,
        explanationAr: json['explanation_ar'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
      );

  ExamResultAnswer toEntity() => ExamResultAnswer(
    questionId: questionId,
    questionTextAr: questionTextAr,
    selectedAnswer: selectedAnswer,
    correctAnswer: correctAnswer,
    isCorrect: isCorrect,
    explanationAr: explanationAr,
    imageFullUrl: imageUrl == null
        ? null
        : ApiConstants.resolveStorageUrl(imageUrl!),
  );
}

/// Data model for the `data` object of
/// `GET /exam-attempts/{attemptId}/results`.
class ExamResultModel {
  const ExamResultModel({
    required this.attempt,
    required this.exam,
    required this.answers,
  });

  final ExamResultAttemptModel attempt;
  final ExamSummaryModel exam;
  final List<ExamResultAnswerModel> answers;

  factory ExamResultModel.fromJson(Map<String, dynamic> json) =>
      ExamResultModel(
        attempt: ExamResultAttemptModel.fromJson(
          json['attempt'] as Map<String, dynamic>? ?? const {},
        ),
        exam: ExamSummaryModel.fromJson(
          json['exam'] as Map<String, dynamic>? ?? const {},
        ),
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map(
              (e) => ExamResultAnswerModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  ExamResultDetail toEntity() => ExamResultDetail(
    attemptId: attempt.id,
    score: attempt.score,
    correctAnswers: attempt.correctAnswers,
    incorrectAnswers: attempt.incorrectAnswers,
    passed: attempt.passed,
    timeTaken: attempt.timeTaken,
    exam: exam.toEntity(),
    answers: answers.map((a) => a.toEntity()).toList(),
  );
}
