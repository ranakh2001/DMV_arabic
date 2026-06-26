import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../models/auth_tokens_model.dart';
import '../models/auth_user_model.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/social_login_request.dart';
import '../models/verify_request.dart';

/// Performs raw HTTP calls using [Dio] and maps responses to models.
/// Throws [ServerException] on API errors; calling layer maps to [Failure].
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> register(RegisterRequest request) async {
    final response = await _post(ApiConstants.register, request.toJson());
    _assertSuccess(response, 'register');
  }

  Future<({AuthUserModel user, AuthTokensModel tokens})> verify(
    VerifyRequest request,
  ) async {
    final response = await _post(ApiConstants.verify, request.toJson());
    _assertSuccess(response, 'verify');
    final data = response.data as Map<String, dynamic>;
    return (
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>),
    );
  }

  Future<void> resendCode(String contact) async {
    final response = await _post(ApiConstants.verify, {'contact': contact, 'resend': true});
    _assertSuccess(response, 'resend_code');
  }

  Future<({AuthUserModel user, AuthTokensModel tokens, String? unverifiedContact})> login(
    LoginRequest request,
  ) async {
    try {
      final response = await _post(ApiConstants.login, request.toJson());
      _assertSuccess(response, 'login');
      final data = response.data as Map<String, dynamic>;
      return (
        user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
        tokens: AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>),
        unverifiedContact: null,
      );
    } on ServerException catch (e) {
      // BR-02: 403 with code UNVERIFIED means account needs verification
      if (e.statusCode == 403 && e.errorCode == 'UNVERIFIED') {
        return (
          user: AuthUserModel(id: '', name: ''),
          tokens: AuthTokensModel(accessToken: '', refreshToken: '', expiresIn: 0),
          unverifiedContact: request.contact,
        );
      }
      rethrow;
    }
  }

  Future<({AuthUserModel user, AuthTokensModel tokens})> socialLogin(
    SocialLoginRequest request,
  ) async {
    final response = await _post(ApiConstants.social, request.toJson());
    _assertSuccess(response, 'social_login');
    final data = response.data as Map<String, dynamic>;
    return (
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Best-effort — local cleanup happens regardless
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    final response = await _post(ApiConstants.forgotPassword, request.toJson());
    _assertSuccess(response, 'forgot_password');
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    final response = await _post(ApiConstants.resetPassword, request.toJson());
    _assertSuccess(response, 'reset_password');
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
      final failure = e.error;
      if (failure != null) throw _dioToServer(e);
      throw _dioToServer(e);
    }
  }

  void _assertSuccess(ApiResponse<dynamic> response, String operation) {
    if (!response.success) {
      throw ServerException(
        messageAr: response.error?.userMessage ??
            'فشلت العملية ($operation). يرجى المحاولة مرة أخرى.',
        messageEn: response.error?.messageEn,
        errorCode: response.error?.code,
      );
    }
  }

  ServerException _dioToServer(DioException e) {
    final response = e.response;
    final body = response?.data;
    String? arMsg;
    String? enMsg;
    String? code;

    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map<String, dynamic>) {
        arMsg = err['message_ar'] as String?;
        enMsg = err['message_en'] as String?;
        code = err['code'] as String?;
      }
    }

    return ServerException(
      messageAr: arMsg ?? 'حدث خطأ. يرجى المحاولة مرة أخرى.',
      messageEn: enMsg,
      statusCode: response?.statusCode,
      errorCode: code,
    );
  }
}
