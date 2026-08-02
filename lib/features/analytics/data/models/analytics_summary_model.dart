import '../../domain/entities/analytics_summary.dart';

/// Data model for the `data` object on `GET /analytics/summary`.
class AnalyticsSummaryModel {
  const AnalyticsSummaryModel({
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
  final double correctRatio;

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) =>
      AnalyticsSummaryModel(
        totalSimulations: json['total_simulations'] as int? ?? 0,
        averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
        highestScore: (json['highest_score'] as num?)?.toDouble() ?? 0,
        totalAnswers: json['total_answers'] as int? ?? 0,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        correctRatio: (json['correct_ratio'] as num?)?.toDouble() ?? 0,
      );

  AnalyticsSummary toEntity() => AnalyticsSummary(
    totalSimulations: totalSimulations,
    averageScore: averageScore,
    highestScore: highestScore,
    totalAnswers: totalAnswers,
    correctAnswers: correctAnswers,
    correctRatio: correctRatio,
  );
}
