import '../../../../core/utils/result.dart';
import '../entities/exam_summary.dart';
import '../repositories/simulation_exam_repository.dart';

class GetSimulationExamsUsecase {
  const GetSimulationExamsUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<List<ExamSummary>>> call({required int stateId}) =>
      _repo.getExams(stateId: stateId);
}
