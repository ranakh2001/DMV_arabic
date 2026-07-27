import '../../../../core/utils/result.dart';
import '../entities/us_state.dart';
import '../repositories/states_repository.dart';

class GetStatesUsecase {
  const GetStatesUsecase(this._repo);
  final StatesRepository _repo;

  Future<Result<List<UsState>>> call() => _repo.getStates();
}
