/// One past simulation's score, from `GET /analytics/progress`.
class AnalyticsProgressEntry {
  const AnalyticsProgressEntry({
    required this.id,
    required this.score,
    required this.createdAt,
  });

  final int id;
  final double score;
  final DateTime createdAt;
}
