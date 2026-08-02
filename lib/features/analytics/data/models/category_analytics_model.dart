import '../../domain/entities/category_analytics.dart';

/// Data model for one row of the `data` array on `GET /analytics/by-category`.
class CategoryAnalyticsModel {
  const CategoryAnalyticsModel({
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.correctRatio,
  });

  final int categoryId;
  final String nameAr;
  final String nameEn;
  final int totalAnswers;
  final int correctAnswers;
  final double correctRatio;

  factory CategoryAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      CategoryAnalyticsModel(
        categoryId: json['category_id'] as int,
        nameAr: json['name_ar'] as String? ?? '',
        nameEn: json['name_en'] as String? ?? '',
        totalAnswers: json['total_answers'] as int? ?? 0,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        correctRatio: (json['correct_ratio'] as num?)?.toDouble() ?? 0,
      );

  CategoryAnalytics toEntity() => CategoryAnalytics(
    categoryId: categoryId,
    nameAr: nameAr,
    nameEn: nameEn,
    totalAnswers: totalAnswers,
    correctAnswers: correctAnswers,
    correctRatio: correctRatio,
  );
}
