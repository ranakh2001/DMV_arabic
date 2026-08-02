/// Per-category answer breakdown, from `GET /analytics/by-category`.
class CategoryAnalytics {
  const CategoryAnalytics({
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

  /// 0–100.
  final double correctRatio;
}
