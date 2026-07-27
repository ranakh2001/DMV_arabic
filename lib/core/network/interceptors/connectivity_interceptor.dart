import 'package:dio/dio.dart';
import '../connectivity_service.dart';

/// Rejects every request up front when there's no real internet reachability,
/// instead of letting it hang until a socket/DNS timeout. [ErrorInterceptor]
/// turns the resulting `connectionError` into a [NetworkFailure] exactly like
/// a real "Failed host lookup" would.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivity);

  final ConnectivityService _connectivity;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (await _connectivity.isConnected) return handler.next(options);
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      ),
    );
  }
}
