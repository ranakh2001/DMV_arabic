/// The user's exam-performance snapshot, embedded in `/users/profile`.
class UserProgress {
  const UserProgress({
    required this.completedExams,
    required this.passedExams,
    required this.averageScore,
    required this.latestScore,
  });

  final int completedExams;
  final int passedExams;
  final double averageScore;
  final double latestScore;
}
