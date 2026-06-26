import '../../../../core/utils/result.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../services/social_auth_service.dart';

class SocialLoginUsecase {
  const SocialLoginUsecase(this._repo, this._social);
  final AuthRepository _repo;
  final SocialAuthService _social;

  Future<Result<AuthSession>> callGoogle() => _call('google', _social.signInWithGoogle);
  Future<Result<AuthSession>> callApple() => _call('apple', _social.signInWithApple);

  Future<Result<AuthSession>> _call(
    String provider,
    Future<String> Function() getToken,
  ) async {
    try {
      final token = await getToken();
      return _repo.socialLogin(provider: provider, token: token);
    } catch (e) {
      return Result.failure(UnavailableFailure(
        messageAr: e.toString(),
      ));
    }
  }
}
