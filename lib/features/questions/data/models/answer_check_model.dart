import '../../domain/entities/answer_check_result.dart';

/// Nested `subscription` object on a `/check-answer` response.
class QuestionCheckSubscriptionInfoModel {
  const QuestionCheckSubscriptionInfoModel({
    required this.hasActiveSubscription,
    required this.upgradeRequired,
    this.freeQuestionsUsed,
    this.freeQuestionsLimit,
    this.remainingFreeQuestions,
  });

  final bool hasActiveSubscription;
  final bool upgradeRequired;
  final int? freeQuestionsUsed;
  final int? freeQuestionsLimit;
  final int? remainingFreeQuestions;

  factory QuestionCheckSubscriptionInfoModel.fromJson(
    Map<String, dynamic> json,
  ) => QuestionCheckSubscriptionInfoModel(
    hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
    upgradeRequired: json['upgrade_required'] as bool? ?? false,
    freeQuestionsUsed: json['free_questions_used'] as int?,
    freeQuestionsLimit: json['free_questions_limit'] as int?,
    remainingFreeQuestions: json['remaining_free_questions'] as int?,
  );
}

/// Data model for the `data` object of `POST /questions/{id}/check-answer`.
class AnswerCheckModel {
  const AnswerCheckModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanationAr,
    required this.subscription,
  });

  final int questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String explanationAr;
  final QuestionCheckSubscriptionInfoModel subscription;

  factory AnswerCheckModel.fromJson(Map<String, dynamic> json) =>
      AnswerCheckModel(
        questionId: json['question_id'] as int,
        selectedAnswer: json['selected_answer'] as String? ?? '',
        isCorrect: json['is_correct'] as bool? ?? false,
        correctAnswer: json['correct_answer'] as String? ?? '',
        explanationAr: json['explanation_ar'] as String? ?? '',
        subscription: QuestionCheckSubscriptionInfoModel.fromJson(
          json['subscription'] as Map<String, dynamic>? ?? const {},
        ),
      );

  AnswerCheckResult toEntity() => AnswerCheckResult(
    questionId: questionId,
    selectedAnswer: selectedAnswer,
    isCorrect: isCorrect,
    correctAnswer: correctAnswer,
    explanationAr: explanationAr,
    hasActiveSubscription: subscription.hasActiveSubscription,
    upgradeRequired: subscription.upgradeRequired,
    freeQuestionsUsed: subscription.freeQuestionsUsed,
    freeQuestionsLimit: subscription.freeQuestionsLimit,
    remainingFreeQuestions: subscription.remainingFreeQuestions,
  );
}
