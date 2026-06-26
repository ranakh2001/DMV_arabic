import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

/// Abstract contract for auth operations. Returns [Result<T, Failure>].
/// Implementations live in the data layer.
abstract interface class AuthRepository {
  /// FR-01: Register with name + (phone or email) + password.
  Future<Result<void>> register({
    required String name,
    required String contact,
    required String password,
  });

  /// FR-02/03: Verify the 6-digit code sent to [contact].
  Future<Result<AuthSession>> verify({
    required String contact,
    required String code,
  });

  /// FR-03: Resend verification code to [contact].
  Future<Result<void>> resendCode({required String contact});

  /// FR-04: Login with (phone or email) + password.
  /// Returns a [String] unverified contact when BR-02 applies,
  /// or [AuthSession] on success.
  Future<Result<({AuthSession? session, String? unverifiedContact})>> login({
    required String contact,
    required String password,
  });

  /// FR-07: Social login via a provider token.
  Future<Result<AuthSession>> socialLogin({
    required String provider,
    required String token,
  });

  /// FR-06: Logout — invalidates server session + wipes secure storage.
  Future<Result<void>> logout();

  /// FR-05 step 1: Send reset code to [contact].
  Future<Result<void>> forgotPassword({required String contact});

  /// FR-05 step 2: Reset password using [code] and [newPassword].
  Future<Result<void>> resetPassword({
    required String contact,
    required String code,
    required String newPassword,
  });

  /// Bootstrap: restore session from secure storage if tokens are still valid.
  Future<Result<AuthUser?>> bootstrapSession();
}
