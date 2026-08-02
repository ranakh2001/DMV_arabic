import '../../domain/entities/analytics_progress_entry.dart';

/// Data model for one row of the `data` array on `GET /analytics/progress`.
class AnalyticsProgressEntryModel {
  const AnalyticsProgressEntryModel({
    required this.id,
    required this.score,
    required this.createdAt,
  });

  final int id;
  final double score;
  final DateTime createdAt;

  factory AnalyticsProgressEntryModel.fromJson(Map<String, dynamic> json) =>
      AnalyticsProgressEntryModel(
        id: json['id'] as int,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  AnalyticsProgressEntry toEntity() =>
      AnalyticsProgressEntry(id: id, score: score, createdAt: createdAt);
}
