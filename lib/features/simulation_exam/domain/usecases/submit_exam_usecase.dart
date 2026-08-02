import '../../../../core/utils/result.dart';
import '../entities/exam_submit_result.dart';
import '../repositories/simulation_exam_repository.dart';

class SubmitExamUsecase {
  const SubmitExamUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<ExamSubmitResult>> call({required int attemptId}) =>
      _repo.submitExam(attemptId: attemptId);
}
