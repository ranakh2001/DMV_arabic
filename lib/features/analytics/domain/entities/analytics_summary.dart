/// Aggregate stats for the signed-in user, from `GET /analytics/summary`.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalSimulations,
    required this.averageScore,
    required this.highestScore,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.correctRatio,
  });

  final int totalSimulations;
  final double averageScore;
  final double highestScore;
  final int totalAnswers;
  final int correctAnswers;

  /// 0–100.
  final double correctRatio;
}
