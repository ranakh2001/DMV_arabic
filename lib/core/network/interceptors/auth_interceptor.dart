import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../storage/secure_storage_service.dart';

/// Attaches Bearer token to every request.
/// On 401: attempts a single token refresh, retries the original request.
/// On refresh failure: wipes tokens and triggers logout via [onLogout].
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
    if (options.path == ApiConstants.refreshToken) return handler.next(options);
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
    if (err.response?.statusCode != 401 || _isRefreshing) return handler.next(err);

    if (err.requestOptions.path == ApiConstants.refreshToken) {
      await onLogout();
      return handler.next(err);
    }

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

      final response = await dio.get(
        ApiConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data == null) return false;
        await secureStorage.saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
          expiry: DateTime.now().add(const Duration(minutes: 15)),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
