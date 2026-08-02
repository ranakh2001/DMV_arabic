import '../../../../core/utils/result.dart';
import '../entities/exam_attempt_start_result.dart';
import '../repositories/simulation_exam_repository.dart';

class StartSimulationExamUsecase {
  const StartSimulationExamUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<ExamAttemptStartResult>> call({required int examId}) =>
      _repo.startExam(examId: examId);
}
