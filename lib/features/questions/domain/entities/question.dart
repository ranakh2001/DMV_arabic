/// A single DMV question, as configured on the backend for a given state.
/// Trimmed to the fields Practice mode (and, later, Simulation) actually
/// consume — see `QuestionModel` in the data layer for the full API shape.
class Question {
  const Question({
    required this.id,
    required this.stateId,
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
    this.imageFullUrl,
  });

  final int id;
  final int stateId;
  final String questionTextAr;
  final String questionTextEn;

  /// `"text"` or `"image"`.
  final String questionType;

  final String optionAAr;
  final String optionBAr;
  final String optionCAr;
  final String optionDAr;
  final String optionAEn;
  final String optionBEn;
  final String optionCEn;
  final String optionDEn;

  /// `"a"`, `"b"`, `"c"` or `"d"`.
  final String correctAnswer;

  final String explanationAr;

  /// Absolute URL (base + relative `image_url`), or null for text questions.
  final String? imageFullUrl;

  bool get isImageQuestion => questionType == 'image';

  /// The question text for the given [isAr] locale, falling back to Arabic
  /// if the localized text is missing.
  String questionText(bool isAr) =>
      (isAr ? questionTextAr : questionTextEn).isNotEmpty
      ? (isAr ? questionTextAr : questionTextEn)
      : questionTextAr;

  /// The option text for option letter [letter] (`'a'..'d'`) in the given
  /// [isAr] locale, falling back to Arabic if the localized text is missing.
  String optionText(String letter, {required bool isAr}) {
    final ar = switch (letter) {
      'a' => optionAAr,
      'b' => optionBAr,
      'c' => optionCAr,
      'd' => optionDAr,
      _ => '',
    };
    if (isAr) return ar;
    final en = switch (letter) {
      'a' => optionAEn,
      'b' => optionBEn,
      'c' => optionCEn,
      'd' => optionDEn,
      _ => '',
    };
    return en.isNotEmpty ? en : ar;
  }
}
