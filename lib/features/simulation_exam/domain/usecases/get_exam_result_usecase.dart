import '../../../../core/utils/result.dart';
import '../entities/exam_result_detail.dart';
import '../repositories/simulation_exam_repository.dart';

class GetExamResultUsecase {
  const GetExamResultUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<ExamResultDetail>> call({required int attemptId}) =>
      _repo.getExamResults(attemptId: attemptId);
}
