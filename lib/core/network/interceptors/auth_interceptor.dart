import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../storage/secure_storage_service.dart';

/// Attaches Bearer token to every request.
/// On 401: attempts a single token refresh, retries the original request.
/// On refresh failure (or if the failing call was the refresh/logout call
/// itself): wipes tokens and triggers logout via [onLogout].
///
/// This is the reactive fallback only — the primary refresh path is
/// proactive, scheduled ahead of expiry by `AuthController` via
/// `RefreshTokenUsecase`. This duplicates the raw HTTP call rather than
/// depending on that usecase because `core/` cannot import `features/auth/`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    required this.onLogout,
  });

  final SecureStorageService secureStorage;
  final Dio dio;
  final Future<void> Function() onLogout;

  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await secureStorage.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    } catch (_) {
      // Storage error: continue without token
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final path = err.requestOptions.path;
    if (path == ApiConstants.logout || path == ApiConstants.refreshToken) {
      // A failing logout/refresh call itself must not trigger another refresh.
      await onLogout();
      return handler.next(err);
    }

    if (_isRefreshing) return handler.next(err);
    _isRefreshing = true;
    try {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        await onLogout();
        return handler.next(err);
      }
      final token = await secureStorage.readAccessToken();
      final opts = err.requestOptions..headers['Authorization'] = 'Bearer $token';
      final response = await dio.fetch(opts);
      return handler.resolve(response);
    } catch (_) {
      await onLogout();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.readRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final body = response.data;
      if (response.statusCode == 200 && body != null && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) return false;
        await secureStorage.saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
          expiry: DateTime.now().add(Duration(seconds: data['expires_in'] as int? ?? 900)),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
