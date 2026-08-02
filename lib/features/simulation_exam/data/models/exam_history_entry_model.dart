import '../../domain/entities/exam_history_entry.dart';

/// One row of the paginated `data.data` array on
/// `GET /exam-attempts/history`.
class ExamHistoryEntryModel {
  const ExamHistoryEntryModel({
    required this.id,
    required this.examTitleAr,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.passed,
    required this.completionStatus,
    required this.startTime,
    this.endTime,
  });

  final int id;
  final String examTitleAr;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool passed;
  final String completionStatus;
  final DateTime startTime;
  final DateTime? endTime;

  factory ExamHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final exam = json['exam'] as Map<String, dynamic>?;
    return ExamHistoryEntryModel(
      id: json['id'] as int,
      examTitleAr: exam?['title_ar'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
      passed: json['passed'] == true,
      completionStatus: json['completion_status'] as String? ?? '',
      startTime:
          DateTime.tryParse(json['start_time'] as String? ?? '') ??
          DateTime.now(),
      endTime: json['end_time'] == null
          ? null
          : DateTime.tryParse(json['end_time'] as String),
    );
  }

  ExamHistoryEntry toEntity() => ExamHistoryEntry(
    id: id,
    examTitleAr: examTitleAr,
    score: score,
    totalQuestions: totalQuestions,
    correctAnswers: correctAnswers,
    incorrectAnswers: incorrectAnswers,
    passed: passed,
    completionStatus: completionStatus,
    startTime: startTime,
    endTime: endTime,
  );
}
