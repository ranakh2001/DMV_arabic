import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request/response logger. Redacts Authorization and token fields.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final headers = Map<String, dynamic>.from(options.headers)
        ..updateAll((k, v) => _redact(k, v));
      debugPrint('[DIO →] ${options.method} ${options.uri}');
      debugPrint('[DIO →] Headers: $headers');
      if (options.data != null) {
        debugPrint('[DIO →] Body: ${_redactBody(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[DIO ←] ${response.statusCode} ${response.requestOptions.uri}',
      );
      if (response.data != null) {
        debugPrint('[DIO ←] Body: ${_redactBody(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[DIO ✗] ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}',
      );
      if (err.response?.data != null) {
        debugPrint('[DIO ✗] Body: ${_redactBody(err.response!.data)}');
      }
    }
    handler.next(err);
  }

  /// Redacts sensitive header values.
  dynamic _redact(String key, dynamic value) {
    final lower = key.toLowerCase();
    if (lower == 'authorization' || lower.contains('token')) return '***';
    return value;
  }

  /// Redacts token/password fields from request body.
  dynamic _redactBody(dynamic body) {
    if (body is Map) {
      return Map.from(body).map((k, v) {
        final lower = k.toString().toLowerCase();
        if (lower.contains('token') ||
            lower.contains('password') ||
            lower == 'access_token' ||
            lower == 'refresh_token') {
          return MapEntry(k, '***');
        }
        return MapEntry(k, v);
      });
    }
    return body;
  }
}
