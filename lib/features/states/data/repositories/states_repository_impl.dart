import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/us_state.dart';
import '../../domain/repositories/states_repository.dart';
import '../datasources/states_remote_data_source.dart';

class StatesRepositoryImpl implements StatesRepository {
  const StatesRepositoryImpl({required StatesRemoteDataSource remote}) : _remote = remote;

  final StatesRemoteDataSource _remote;

  @override
  Future<Result<List<UsState>>> getStates() async {
    try {
      final models = await _remote.getStates();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(ApiFailure(
        messageAr: e.messageAr,
        messageEn: e.messageEn,
        statusCode: e.statusCode,
        errorCode: e.errorCode,
      ));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
