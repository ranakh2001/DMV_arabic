import '../../../../core/utils/result.dart';
import '../entities/about_info.dart';
import '../repositories/legal_repository.dart';

class GetAboutUsUsecase {
  const GetAboutUsUsecase(this._repo);
  final LegalRepository _repo;

  Future<Result<AboutInfo>> call() => _repo.getAboutUs();
}
