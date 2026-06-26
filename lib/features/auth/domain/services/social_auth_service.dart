/// Interface for native social-login providers (Apple / Google).
/// Real SDK implementations are plugged in during v2.
abstract interface class SocialAuthService {
  /// Returns the provider JWT token to exchange with the backend.
  Future<String> signInWithGoogle();
  Future<String> signInWithApple();
}

/// Stub that surfaces a localized "unavailable" error.
/// Replaced by a real implementation when social SDKs are added.
class UnavailableSocialAuthService implements SocialAuthService {
  const UnavailableSocialAuthService();

  @override
  Future<String> signInWithGoogle() => _unavailable();

  @override
  Future<String> signInWithApple() => _unavailable();

  Future<String> _unavailable() =>
      Future.error('تسجيل الدخول الاجتماعي غير متاح حالياً.');
}
