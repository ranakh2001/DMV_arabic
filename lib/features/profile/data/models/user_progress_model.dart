import '../../domain/entities/user_progress.dart';

/// Data model for the `data.progress` object on `/users/profile`.
class UserProgressModel {
  const UserProgressModel({
    required this.completedExams,
    required this.passedExams,
    required this.averageScore,
    required this.latestScore,
  });

  final int completedExams;
  final int passedExams;
  final double averageScore;
  final double latestScore;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        completedExams: json['completed_exams'] as int? ?? 0,
        passedExams: json['passed_exams'] as int? ?? 0,
        averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
        latestScore: (json['latest_score'] as num?)?.toDouble() ?? 0,
      );

  UserProgress toEntity() => UserProgress(
    completedExams: completedExams,
    passedExams: passedExams,
    averageScore: averageScore,
    latestScore: latestScore,
  );
}
