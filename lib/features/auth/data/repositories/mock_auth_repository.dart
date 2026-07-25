import '../../../../core/errors/failure.dart';
import '../../../../core/storage/prefs_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class _MockUser {
  _MockUser({
    required this.name,
    required this.contact,
    required this.password,
    this.isVerified = false,
  });

  String name;
  final String contact;
  String password;
  bool isVerified;
}

/// In-memory stand-in for the real backend. Mirrors the [AuthRepository]
/// contract (including latency) so screens behave exactly as they will once
/// the API is wired up — no network calls are made.
///
/// Seeded demo account: contact `demo@dmv.com` or `+11234567890`,
/// password `password123`. Any new registration uses fixed code `123456`.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required SecureStorageService secureStorage,
    required PrefsService prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs {
    _seed();
  }

  final SecureStorageService _secureStorage;
  final PrefsService _prefs;

  final Map<String, _MockUser> _users = {};
  final Map<String, String> _pendingCodes = {};

  static const _fixedCode = '123456';
  static const _latency = Duration(milliseconds: 600);

  void _seed() {
    for (final contact in ['demo@dmv.com', '+11234567890']) {
      _users[contact] = _MockUser(
        name: 'مستخدم تجريبي',
        contact: contact,
        password: 'password123',
        isVerified: true,
      );
    }
  }

  @override
  Future<Result<void>> register({
    required String name,
    required String contact,
    required String password,
  }) async {
    await Future.delayed(_latency);
    if (_users.containsKey(contact)) {
      return Result.failure(const ApiFailure(
        messageAr: 'هذا الحساب مسجل مسبقاً.',
        messageEn: 'This account already exists.',
        statusCode: 409,
      ));
    }
    _users[contact] = _MockUser(name: name, contact: contact, password: password);
    _pendingCodes[contact] = _fixedCode;
    return const Result.success(null);
  }

  @override
  Future<Result<AuthSession>> verify({
    required String contact,
    required String code,
  }) async {
    await Future.delayed(_latency);
    final user = _users[contact];
    if (user == null) {
      return Result.failure(const ApiFailure(messageAr: 'الحساب غير موجود.', statusCode: 404));
    }
    if (_pendingCodes[contact] != code) {
      return Result.failure(const ApiFailure(
        messageAr: 'رمز التحقق غير صحيح.',
        messageEn: 'Invalid verification code.',
        statusCode: 400,
      ));
    }
    user.isVerified = true;
    _pendingCodes.remove(contact);
    return Result.success(await _issueSession(user));
  }

  @override
  Future<Result<void>> resendCode({required String contact}) async {
    await Future.delayed(_latency);
    _pendingCodes[contact] = _fixedCode;
    return const Result.success(null);
  }

  @override
  Future<Result<({AuthSession? session, String? unverifiedContact})>> login({
    required String contact,
    required String password,
  }) async {
    await Future.delayed(_latency);
    final user = _users[contact];
    if (user == null || user.password != password) {
      return Result.failure(const ApiFailure(
        messageAr: 'رقم الهاتف/البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        messageEn: 'Invalid credentials.',
        statusCode: 401,
      ));
    }
    if (!user.isVerified) {
      _pendingCodes[contact] = _fixedCode;
      return Result.success((session: null, unverifiedContact: contact));
    }
    return Result.success((session: await _issueSession(user), unverifiedContact: null));
  }

  @override
  Future<Result<AuthSession>> socialLogin({
    required String provider,
    required String token,
  }) async {
    await Future.delayed(_latency);
    return Result.failure(const UnavailableFailure());
  }

  @override
  Future<Result<void>> logout() async {
    await _secureStorage.clearAll();
    await _prefs.clearUserData();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> forgotPassword({required String contact}) async {
    await Future.delayed(_latency);
    if (!_users.containsKey(contact)) {
      return Result.failure(const ApiFailure(messageAr: 'الحساب غير موجود.', statusCode: 404));
    }
    _pendingCodes[contact] = _fixedCode;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> resetPassword({
    required String contact,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(_latency);
    final user = _users[contact];
    if (user == null) {
      return Result.failure(const ApiFailure(messageAr: 'الحساب غير موجود.', statusCode: 404));
    }
    if (_pendingCodes[contact] != code) {
      return Result.failure(const ApiFailure(messageAr: 'رمز التحقق غير صحيح.', statusCode: 400));
    }
    user.password = newPassword;
    _pendingCodes.remove(contact);
    return const Result.success(null);
  }

  @override
  Future<Result<AuthUser?>> bootstrapSession() async {
    try {
      final hasToken = await _secureStorage.hasValidToken();
      if (!hasToken) return const Result.success(null);

      final name = _prefs.userName;
      if (name == null) return const Result.success(null);

      return Result.success(AuthUser(
        id: 'cached',
        name: name,
        email: _prefs.userEmail,
        phone: _prefs.userPhone,
        isVerified: true,
      ));
    } catch (_) {
      return const Result.success(null);
    }
  }

  Future<AuthSession> _issueSession(_MockUser user) async {
    final expiresAt = DateTime.now().add(const Duration(days: 7));
    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.saveTokens(
      accessToken: token,
      refreshToken: token,
      expiry: expiresAt,
    );

    final isEmail = user.contact.contains('@');
    await _prefs.setUserName(user.name);
    if (isEmail) {
      await _prefs.setUserEmail(user.contact);
    } else {
      await _prefs.setUserPhone(user.contact);
    }

    return AuthSession(
      user: AuthUser(
        id: user.contact,
        name: user.name,
        email: isEmail ? user.contact : null,
        phone: isEmail ? null : user.contact,
        isVerified: true,
      ),
      accessToken: token,
      refreshToken: token,
      expiresAt: expiresAt,
    );
  }
}
