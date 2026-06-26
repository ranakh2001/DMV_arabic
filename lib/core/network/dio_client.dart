import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Creates and configures the [Dio] instance.
///
/// Security: non-HTTPS base URLs are rejected at startup.
/// TLS certificate validation is NOT disabled (default behavior, no `badCertificateCallback`).
Dio createDio() {
  assert(
    ApiConstants.baseUrl.startsWith('https://'),
    'API base URL must use HTTPS. Got: ${ApiConstants.baseUrl}',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    ErrorInterceptor(),
    LoggingInterceptor(),
  ]);

  return dio;
}
