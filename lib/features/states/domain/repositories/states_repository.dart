import '../../../../core/utils/result.dart';
import '../entities/us_state.dart';

abstract interface class StatesRepository {
  Future<Result<List<UsState>>> getStates();
}
