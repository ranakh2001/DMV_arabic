import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/prefs_service.dart';
import '../../../../core/utils/result.dart';
import '../../../states/domain/repositories/states_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_user_model.dart';
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
    required StatesRepository statesRepository,
  }) : _remote = remote,
       _secureStorage = secureStorage,
       _prefs = prefs,
       _statesRepository = statesRepository;

  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;
  final PrefsService _prefs;
  final StatesRepository _statesRepository;

  @override
  Future<Result<void>> register({
    required String name,
    required String contact,
    required int stateId,
    required String password,
  }) async {
    try {
      await _remote.register(
        RegisterRequest(
          fullName: name,
          phoneNumber: contact,
          stateId: stateId,
          password: password,
          passwordConfirmation: password,
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
  Future<Result<AuthSession>> verify({
    required String contact,
    required String code,
  }) async {
    try {
      final result = await _remote.verify(
        VerifyRequest(phoneNumber: contact, code: code),
      );
      final session = await _persistSession(
        result.user.toEntity(),
        result.tokens.accessToken,
        result.tokens.refreshToken,
        result.tokens.expiresAt,
      );
      await _cacheUserToPrefs(session.user);
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
      final result = await _remote.login(
        LoginRequest(phoneNumber: contact, password: password),
      );

      if (result.unverifiedContact != null) {
        return Result.success((
          session: null,
          unverifiedContact: result.unverifiedContact,
        ));
      }

      final session = await _persistSession(
        result.user.toEntity(),
        result.tokens.accessToken,
        result.tokens.refreshToken,
        result.tokens.expiresAt,
      );
      await _cacheUserToPrefs(session.user);

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
        return Result.failure(
          const ApiFailure(messageAr: 'لا توجد جلسة صالحة.'),
        );
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
      if (accessToken == null) {
        debugPrint('[auth] bootstrap: no access token stored');
        return const Result.success(null);
      }

      // Access token may have expired while the app was closed (it's
      // short-lived) — that alone doesn't mean the session is dead, so try
      // the still-valid refresh token before giving up on it.
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        debugPrint(
          '[auth] bootstrap: access token expired, attempting refresh',
        );
        final refreshResult = await refreshToken();
        if (refreshResult.isFailure) {
          final failure = refreshResult.failureOrNull;
          debugPrint(
            '[auth] bootstrap: refresh failed (${failure?.messageEn})',
          );
          // Only a confirmed-dead refresh token (auth/storage failure) logs
          // the user out; a network hiccup at launch should not, and neither
          // wipes the stored tokens — they may still be good on the next try.
          if (failure is! NetworkFailure) {
            await _secureStorage.clearAll();
          }
          return const Result.success(null);
        }
      }

      // The token is (now) valid — confirm the session against the backend
      // and refresh the cached user/state from it, rather than trusting a
      // local cache that can drift from what the server actually has.
      try {
        final profileJson = await _remote.fetchProfile();
        final user = AuthUserModel.fromJson(profileJson).toEntity();
        await _cacheUserToPrefs(user);
        await _syncSelectedState(profileJson);
        debugPrint('[auth] bootstrap: authenticated as ${user.name}');
        return Result.success(user);
      } on ServerException catch (e) {
        debugPrint(
          '[auth] bootstrap: profile fetch failed (${e.statusCode}: ${e.messageAr})',
        );
        // A confirmed-unauthorized profile call means the token is dead
        // despite passing the local expiry check — wipe it. Anything else
        // (server hiccup, timeout) should not destroy an otherwise-valid
        // session; just sit out this launch as unauthenticated.
        if (e.statusCode == 401) await _secureStorage.clearAll();
        return const Result.success(null);
      }
    } on StorageException catch (e) {
      // A transient local read error (e.g. keystore hiccup) is not proof the
      // session is invalid — don't wipe tokens for it, just fail this launch
      // and let the next one try again.
      debugPrint(
        '[auth] bootstrap: storage read failed (${e.message}), tokens kept',
      );
      return const Result.success(null);
    } catch (_) {
      return const Result.success(null);
    }
  }

  Future<void> _cacheUserToPrefs(AuthUser user) async {
    await _prefs.setUserName(user.name);
    if (user.email != null) await _prefs.setUserEmail(user.email!);
    if (user.phone != null) await _prefs.setUserPhone(user.phone!);
  }

  /// Persists the backend's `selected_state_id` (and its resolved display
  /// name) locally, so screens gated on [PrefsService.selectedStateId] work
  /// for a session restored on a device that never ran onboarding/register
  /// locally (e.g. after a reinstall, or signing in on a second device).
  Future<void> _syncSelectedState(Map<String, dynamic> profileJson) async {
    final rawId = profileJson['selected_state_id'];
    final stateId = rawId == null ? null : int.tryParse(rawId.toString());
    if (stateId == null) return;

    await _prefs.setSelectedStateId(stateId);

    final statesResult = await _statesRepository.getStates();
    for (final state in statesResult.valueOrNull ?? const []) {
      if (state.id == stateId) {
        await _prefs.setSelectedState(state.nameAr);
        break;
      }
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
