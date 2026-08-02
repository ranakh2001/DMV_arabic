import '../../../../core/utils/result.dart';
import '../entities/exam_answer_result.dart';
import '../entities/exam_attempt_start_result.dart';
import '../entities/exam_history_entry.dart';
import '../entities/exam_result_detail.dart';
import '../entities/exam_submit_result.dart';
import '../entities/exam_summary.dart';

abstract interface class SimulationExamRepository {
  Future<Result<List<ExamSummary>>> getExams({required int stateId});

  Future<Result<ExamAttemptStartResult>> startExam({required int examId});

  Future<Result<ExamAnswerResult>> answerQuestion({
    required int attemptId,
    required int questionId,
    required String selectedAnswer,
  });

  Future<Result<ExamSubmitResult>> submitExam({required int attemptId});

  Future<Result<ExamResultDetail>> getExamResults({required int attemptId});

  Future<Result<List<ExamHistoryEntry>>> getExamHistory();
}
