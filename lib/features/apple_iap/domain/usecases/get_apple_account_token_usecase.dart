import '../../../../core/utils/result.dart';
import '../repositories/apple_iap_repository.dart';

class GetAppleAccountTokenUsecase {
  const GetAppleAccountTokenUsecase(this._repository);

  final AppleIapRepository _repository;

  Future<Result<String>> call() => _repository.getAccountToken();
}
