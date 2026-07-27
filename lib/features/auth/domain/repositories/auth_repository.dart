import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

/// Abstract contract for auth operations. Returns [Result<T, Failure>].
/// Implementations live in the data layer.
abstract interface class AuthRepository {
  /// FR-01: Register with name + phone + state + password.
  Future<Result<void>> register({
    required String name,
    required String contact,
    required int stateId,
    required String password,
  });

  /// FR-02/03: Verify the 6-digit code sent to [contact].
  Future<Result<AuthSession>> verify({
    required String contact,
    required String code,
  });

  /// FR-03: Resend the verification code to [contact].
  Future<Result<void>> resendVerificationCode({required String contact});

  /// FR-04: Login with phone + password.
  /// Returns a [String] unverified contact when BR-02 applies,
  /// or [AuthSession] on success.
  Future<Result<({AuthSession? session, String? unverifiedContact})>> login({
    required String contact,
    required String password,
  });

  /// FR-06: Logout — invalidates the server session (best-effort) and always
  /// wipes secure storage locally.
  Future<Result<void>> logout();

  /// Exchanges the stored refresh token for a new token pair, persists it,
  /// and returns the new expiry so the caller can reschedule the next refresh.
  Future<Result<DateTime>> refreshToken();

  /// FR-05 step 1: Send reset code to [contact].
  Future<Result<void>> forgotPassword({required String contact});

  /// FR-05 step 2: Reset password using [code] and [newPassword].
  Future<Result<void>> resetPassword({
    required String contact,
    required String code,
    required String newPassword,
  });

  /// FR-05 step 1.5: Check the reset code is correct before letting the user
  /// move on to the new-password screen. Uses the same /auth/verify endpoint
  /// as account verification, but does not establish a session — the account
  /// stays logged out until [resetPassword] actually succeeds.
  Future<Result<void>> verifyResetCode({
    required String contact,
    required String code,
  });

  /// Bootstrap: restore session from secure storage if tokens are still valid.
  Future<Result<AuthUser?>> bootstrapSession();
}
