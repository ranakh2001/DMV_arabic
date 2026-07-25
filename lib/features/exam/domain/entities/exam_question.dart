import 'package:flutter/widgets.dart';
import 'answer_option.dart';

/// A single exam question. Prompt text carries both languages directly
/// (unlike short UI chrome strings) since a question bank is content data,
/// not app copy — keeping hundreds of one-off entries out of the global
/// localization maps.
class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.mediaIcon,
    required this.promptEn,
    required this.promptAr,
    required this.options,
    required this.correctOptionId,
  });

  final String id;
  final IconData mediaIcon;
  final String promptEn;
  final String promptAr;
  final List<AnswerOption> options;
  final String correctOptionId;

  String prompt(bool isAr) => isAr ? promptAr : promptEn;

  ExamQuestion copyWith({String? id}) => ExamQuestion(
        id: id ?? this.id,
        mediaIcon: mediaIcon,
        promptEn: promptEn,
        promptAr: promptAr,
        options: options,
        correctOptionId: correctOptionId,
      );
}
