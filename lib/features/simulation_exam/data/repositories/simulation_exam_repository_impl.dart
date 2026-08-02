import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/exam_answer_result.dart';
import '../../domain/entities/exam_attempt_start_result.dart';
import '../../domain/entities/exam_history_entry.dart';
import '../../domain/entities/exam_result_detail.dart';
import '../../domain/entities/exam_submit_result.dart';
import '../../domain/entities/exam_summary.dart';
import '../../domain/repositories/simulation_exam_repository.dart';
import '../datasources/simulation_exam_remote_data_source.dart';

class SimulationExamRepositoryImpl implements SimulationExamRepository {
  const SimulationExamRepositoryImpl({
    required SimulationExamRemoteDataSource remote,
  }) : _remote = remote;

  final SimulationExamRemoteDataSource _remote;

  @override
  Future<Result<List<ExamSummary>>> getExams({required int stateId}) async {
    try {
      final models = await _remote.getExams(stateId: stateId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<ExamAttemptStartResult>> startExam({
    required int examId,
  }) async {
    try {
      final model = await _remote.startExam(examId: examId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<ExamAnswerResult>> answerQuestion({
    required int attemptId,
    required int questionId,
    required String selectedAnswer,
  }) async {
    try {
      final model = await _remote.answerQuestion(
        attemptId: attemptId,
        questionId: questionId,
        selectedAnswer: selectedAnswer,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<ExamSubmitResult>> submitExam({required int attemptId}) async {
    try {
      final model = await _remote.submitExam(attemptId: attemptId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<ExamResultDetail>> getExamResults({
    required int attemptId,
  }) async {
    try {
      final model = await _remote.getExamResults(attemptId: attemptId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<ExamHistoryEntry>>> getExamHistory() async {
    try {
      final models = await _remote.getExamHistory();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  ApiFailure _toApiFailure(ServerException e) => ApiFailure(
    messageAr: e.messageAr,
    messageEn: e.messageEn,
    statusCode: e.statusCode,
    errorCode: e.errorCode,
  );
}
