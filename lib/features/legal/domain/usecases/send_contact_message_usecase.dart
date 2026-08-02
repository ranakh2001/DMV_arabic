import '../../../../core/utils/result.dart';
import '../repositories/legal_repository.dart';

class SendContactMessageUsecase {
  const SendContactMessageUsecase(this._repo);
  final LegalRepository _repo;

  Future<Result<String>> call(String message) =>
      _repo.sendContactMessage(message);
}
