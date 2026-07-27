import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/prefs_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/resend_verification_code_request.dart';
import '../models/reset_password_request.dart';
import '../models/verify_request.dart';

/// Concrete implementation of [AuthRepository].
/// Converts exceptions to [Result.failure] with localized [Failure] values.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStorageService secureStorage,
    required PrefsService prefs,
  })  : _remote = remote,
        _secureStorage = secureStorage,
        _prefs = prefs;

  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;
  final PrefsService _prefs;

  @override
  Future<Result<void>> register({
    required String name,
    required String contact,
    required int stateId,
    required String password,
  }) async {
    try {
      await _remote.register(RegisterRequest(
        fullName: name,
        phoneNumber: contact,
        stateId: stateId,
        password: password,
        passwordConfirmation: password,
      ));
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AuthSession>> verify({
    required String contact,
    required String code,
  }) async {
    try {
      final result = await _remote.verify(VerifyRequest(phoneNumber: contact, code: code));
      final session = await _persistSession(result.user.toEntity(), result.tokens.accessToken,
          result.tokens.refreshToken, result.tokens.expiresAt);
      await _prefs.setUserName(result.user.name);
      if (result.user.email != null) await _prefs.setUserEmail(result.user.email!);
      if (result.user.phone != null) await _prefs.setUserPhone(result.user.phone!);
      return Result.success(session);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> resendVerificationCode({required String contact}) async {
    try {
      await _remote.resendVerificationCode(
        ResendVerificationCodeRequest(phoneNumber: contact),
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<({AuthSession? session, String? unverifiedContact})>> login({
    required String contact,
    required String password,
  }) async {
    try {
      final result = await _remote.login(LoginRequest(phoneNumber: contact, password: password));

      if (result.unverifiedContact != null) {
        return Result.success((session: null, unverifiedContact: result.unverifiedContact));
      }

      final session = await _persistSession(
        result.user.toEntity(),
        result.tokens.accessToken,
        result.tokens.refreshToken,
        result.tokens.expiresAt,
      );
      await _prefs.setUserName(result.user.name);
      if (result.user.email != null) await _prefs.setUserEmail(result.user.email!);
      if (result.user.phone != null) await _prefs.setUserPhone(result.user.phone!);

      return Result.success((session: session, unverifiedContact: null));
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    // Best-effort server invalidation; local session is wiped regardless.
    await _remote.logout();
    try {
      await _secureStorage.clearAll();
      await _prefs.clearUserData();
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(messageAr: e.message));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<DateTime>> refreshToken() async {
    try {
      final refresh = await _secureStorage.readRefreshToken();
      if (refresh == null) {
        return Result.failure(const ApiFailure(messageAr: 'لا توجد جلسة صالحة.'));
      }
      final tokens = await _remote.refreshToken(refresh);
      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiry: tokens.expiresAt,
      );
      return Result.success(tokens.expiresAt);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> forgotPassword({required String contact}) async {
    try {
      await _remote.forgotPassword(ForgotPasswordRequest(phoneNumber: contact));
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String contact,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(
        ResetPasswordRequest(
          phoneNumber: contact,
          code: code,
          password: newPassword,
          passwordConfirmation: newPassword,
        ),
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> verifyResetCode({
    required String contact,
    required String code,
  }) async {
    try {
      await _remote.verify(VerifyRequest(phoneNumber: contact, code: code));
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AuthUser?>> bootstrapSession() async {
    try {
      final accessToken = await _secureStorage.readAccessToken();
      if (accessToken == null) return const Result.success(null);

      // Access token may have expired while the app was closed (it's
      // short-lived) — that alone doesn't mean the session is dead, so try
      // the still-valid refresh token before giving up on it.
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        final refreshResult = await refreshToken();
        if (refreshResult.isFailure) {
          // Only a confirmed-dead refresh token (auth/storage failure) logs
          // the user out; a network hiccup at launch should not.
          if (refreshResult.failureOrNull is! NetworkFailure) {
            await _secureStorage.clearAll();
            return const Result.success(null);
          }
        }
      }

      // Restore user from prefs cache (non-sensitive)
      final name = _prefs.userName;
      final email = _prefs.userEmail;
      final phone = _prefs.userPhone;

      if (name == null) return const Result.success(null);

      return Result.success(AuthUser(
        id: 'cached',
        name: name,
        email: email,
        phone: phone,
        isVerified: true,
      ));
    } on StorageException catch (_) {
      // Storage corruption: treat as unauthenticated and wipe
      await _secureStorage.clearAll();
      return Result.failure(const StorageFailure());
    } catch (_) {
      return const Result.success(null);
    }
  }

  Future<AuthSession> _persistSession(
    AuthUser user,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  ) async {
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiresAt,
    );
    return AuthSession(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  ApiFailure _fromServer(ServerException e) => ApiFailure(
        messageAr: e.messageAr,
        messageEn: e.messageEn,
        statusCode: e.statusCode,
        errorCode: e.errorCode,
      );
}
