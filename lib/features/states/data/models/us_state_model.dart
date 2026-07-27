import '../../domain/entities/us_state.dart';

/// Data model for a single object in the `/states` list response.
class UsStateModel {
  const UsStateModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.abbreviation,
    required this.dmvQuestionCount,
    required this.dmvPassingScore,
    this.iconUrl,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final String abbreviation;
  final int dmvQuestionCount;
  final int dmvPassingScore;
  final String? iconUrl;

  factory UsStateModel.fromJson(Map<String, dynamic> json) => UsStateModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String? ?? '',
        nameAr: json['name_ar'] as String? ?? '',
        abbreviation: json['abbreviation'] as String? ?? '',
        dmvQuestionCount: json['dmv_question_count'] as int? ?? 0,
        dmvPassingScore: json['dmv_passing_score'] as int? ?? 0,
        iconUrl: json['icon_url'] as String?,
      );

  UsState toEntity() => UsState(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        abbreviation: abbreviation,
        dmvQuestionCount: dmvQuestionCount,
        dmvPassingScore: dmvPassingScore,
        iconUrl: iconUrl,
      );
}
