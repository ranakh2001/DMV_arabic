import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/question.dart';

/// Nested `state` object on a question, as returned by `/questions`.
class QuestionStateRefModel {
  const QuestionStateRefModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final int id;
  final String nameEn;
  final String nameAr;

  factory QuestionStateRefModel.fromJson(Map<String, dynamic> json) =>
      QuestionStateRefModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String? ?? '',
        nameAr: json['name_ar'] as String? ?? '',
      );
}

/// Nested `category` object on a question, as returned by `/questions`.
class QuestionCategoryModel {
  const QuestionCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryType,
  });

  final int id;
  final String nameEn;
  final String nameAr;

  /// `"signs"` or `"general"`.
  final String categoryType;

  factory QuestionCategoryModel.fromJson(Map<String, dynamic> json) =>
      QuestionCategoryModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String? ?? '',
        nameAr: json['name_ar'] as String? ?? '',
        categoryType: json['category_type'] as String? ?? '',
      );
}

/// Data model for a single object in the `/questions` list response.
/// Mirrors the API payload field-for-field; [toEntity] projects it down to
/// what the app's presentation layer needs.
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.stateId,
    required this.categoryId,
    required this.questionTextAr,
    required this.questionTextEn,
    required this.questionType,
    required this.optionAAr,
    required this.optionBAr,
    required this.optionCAr,
    required this.optionDAr,
    required this.optionAEn,
    required this.optionBEn,
    required this.optionCEn,
    required this.optionDEn,
    required this.correctAnswer,
    required this.explanationAr,
    required this.difficultyLevel,
    this.imageUrl,
    this.state,
    this.category,
  });

  final int id;
  final int stateId;
  final int categoryId;
  final String questionTextAr;
  final String questionTextEn;
  final String questionType;
  final String? imageUrl;
  final String optionAAr;
  final String optionBAr;
  final String optionCAr;
  final String optionDAr;
  final String optionAEn;
  final String optionBEn;
  final String optionCEn;
  final String optionDEn;
  final String correctAnswer;
  final String explanationAr;
  final String difficultyLevel;
  final QuestionStateRefModel? state;
  final QuestionCategoryModel? category;

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'] as int,
    stateId: json['state_id'] as int,
    categoryId: json['category_id'] as int,
    questionTextAr: json['question_text_ar'] as String? ?? '',
    questionTextEn: json['question_text_en'] as String? ?? '',
    questionType: json['question_type'] as String? ?? 'text',
    imageUrl: json['image_url'] as String?,
    optionAAr: json['option_a_ar'] as String? ?? '',
    optionBAr: json['option_b_ar'] as String? ?? '',
    optionCAr: json['option_c_ar'] as String? ?? '',
    optionDAr: json['option_d_ar'] as String? ?? '',
    optionAEn: json['option_a_en'] as String? ?? '',
    optionBEn: json['option_b_en'] as String? ?? '',
    optionCEn: json['option_c_en'] as String? ?? '',
    optionDEn: json['option_d_en'] as String? ?? '',
    correctAnswer: json['correct_answer'] as String? ?? '',
    explanationAr: json['explanation_ar'] as String? ?? '',
    difficultyLevel: json['difficulty_level'] as String? ?? '',
    state: json['state'] == null
        ? null
        : QuestionStateRefModel.fromJson(json['state'] as Map<String, dynamic>),
    category: json['category'] == null
        ? null
        : QuestionCategoryModel.fromJson(
            json['category'] as Map<String, dynamic>,
          ),
  );

  Question toEntity() => Question(
    id: id,
    stateId: stateId,
    questionTextAr: questionTextAr,
    questionTextEn: questionTextEn,
    questionType: questionType,
    optionAAr: optionAAr,
    optionBAr: optionBAr,
    optionCAr: optionCAr,
    optionDAr: optionDAr,
    optionAEn: optionAEn,
    optionBEn: optionBEn,
    optionCEn: optionCEn,
    optionDEn: optionDEn,
    correctAnswer: correctAnswer,
    explanationAr: explanationAr,
    imageFullUrl: imageUrl == null
        ? null
        : ApiConstants.resolveStorageUrl(imageUrl!),
  );
}
