import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../models/auth_tokens_model.dart';
import '../models/auth_user_model.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/resend_verification_code_request.dart';
import '../models/reset_password_request.dart';
import '../models/verify_request.dart';

/// Performs raw HTTP calls using [Dio] and maps responses to models.
/// Throws [ServerException] on API errors; calling layer maps to [Failure].
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> register(RegisterRequest request) async {
    final response = await _post(ApiConstants.register, request.toJson());
    _assertSuccess(response);
  }

  Future<({AuthUserModel user, AuthTokensModel tokens})> verify(
    VerifyRequest request,
  ) async {
    final response = await _post(ApiConstants.verify, request.toJson());
    _assertSuccess(response);
    final data = response.data as Map<String, dynamic>;
    return (
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data),
    );
  }

  /// Returns [unverifiedContact] set to [request.phoneNumber] when the API
  /// reports the account isn't verified yet (BR-02) — the API has no
  /// dedicated error code for this, so it is detected from the message text.
  Future<
    ({AuthUserModel user, AuthTokensModel tokens, String? unverifiedContact})
  >
  login(LoginRequest request) async {
    final response = await _post(ApiConstants.login, request.toJson());

    if (!response.success) {
      if (_looksUnverified(response.message)) {
        return (
          user: AuthUserModel(id: '', name: ''),
          tokens: AuthTokensModel(
            accessToken: '',
            refreshToken: '',
            expiresIn: 0,
          ),
          unverifiedContact: request.phoneNumber,
        );
      }
      throw ServerException(messageAr: response.userMessage);
    }

    final data = response.data as Map<String, dynamic>;
    return (
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data),
      unverifiedContact: null,
    );
  }

  /// Exchanges [refreshToken] for a new token pair. Sent as the Bearer
  /// credential on a plain GET — the API takes no body for this endpoint.
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );
      final json = response.data ?? {};
      final apiResponse = ApiResponse<dynamic>.fromJson(json, (data) => data);
      if (!apiResponse.success) {
        throw ServerException(messageAr: apiResponse.userMessage);
      }
      return AuthTokensModel.fromJson(apiResponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _dioToServer(e);
    }
  }

  /// Fetches the current user's profile (`GET /users/profile`) — used by
  /// [AuthRepositoryImpl.bootstrapSession] as the source of truth for
  /// "is this session still valid, and who is the user", instead of trusting
  /// a locally cached name.
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.profile,
      );
      final json = response.data ?? {};
      final apiResponse = ApiResponse<dynamic>.fromJson(json, (data) => data);
      if (!apiResponse.success) {
        throw ServerException(messageAr: apiResponse.userMessage);
      }
      return apiResponse.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _dioToServer(e);
    }
  }

  /// Best-effort — local session cleanup happens regardless of the result.
  Future<void> logout() async {
    try {
      await _dio.get(ApiConstants.logout);
    } catch (_) {
      // Ignore: the local session is wiped either way.
    }
  }

  Future<void> resendVerificationCode(
    ResendVerificationCodeRequest request,
  ) async {
    final response = await _post(
      ApiConstants.resendVerificationCode,
      request.toJson(),
    );
    _assertSuccess(response);
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    final response = await _post(ApiConstants.forgotPassword, request.toJson());
    _assertSuccess(response);
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    final response = await _post(ApiConstants.resetPassword, request.toJson());
    _assertSuccess(response);
  }

  bool _looksUnverified(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('verify') ||
        message.contains('تحقق') ||
        message.contains('توثيق');
  }

  Future<ApiResponse<dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final json = response.data ?? {};
      return ApiResponse<dynamic>.fromJson(json, (data) => data);
    } on DioException catch (e) {
      throw _dioToServer(e);
    }
  }

  void _assertSuccess(ApiResponse<dynamic> response) {
    if (!response.success) {
      throw ServerException(messageAr: response.userMessage);
    }
  }

  ServerException _dioToServer(DioException e) {
    final body = e.response?.data;
    final message = body is Map<String, dynamic>
        ? body['message'] as String?
        : null;
    return ServerException(
      messageAr: message ?? 'حدث خطأ. يرجى المحاولة مرة أخرى.',
      statusCode: e.response?.statusCode,
    );
  }
}
