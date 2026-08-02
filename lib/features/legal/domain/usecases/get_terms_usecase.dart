import '../../../../core/utils/result.dart';
import '../entities/legal_content.dart';
import '../repositories/legal_repository.dart';

class GetTermsUsecase {
  const GetTermsUsecase(this._repo);
  final LegalRepository _repo;

  Future<Result<LegalContent>> call() => _repo.getTerms();
}
