import '../../../../core/utils/result.dart';
import '../entities/exam_history_entry.dart';
import '../repositories/simulation_exam_repository.dart';

class GetExamHistoryUsecase {
  const GetExamHistoryUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<List<ExamHistoryEntry>>> call() => _repo.getExamHistory();
}
