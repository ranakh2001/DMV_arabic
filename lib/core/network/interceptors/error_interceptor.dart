import 'package:dio/dio.dart';
import '../../errors/failure.dart';

/// Converts [DioException] into typed [Failure] instances.
/// Arabic-first error messages are preferred from the API envelope.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _toFailure(err);
    // Attach the failure to the error's extra for downstream use.
    handler.next(err.copyWith(error: failure));
  }

  Failure _toFailure(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiFailure(
          messageAr: 'انتهت مهلة الطلب. تحقق من اتصالك.',
          messageEn: 'Request timed out. Check your connection.',
          errorCode: 'TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _fromResponse(err.response);

      case DioExceptionType.cancel:
        return const ApiFailure(
          messageAr: 'تم إلغاء الطلب.',
          messageEn: 'Request was cancelled.',
          errorCode: 'CANCELLED',
        );

      default:
        return const ApiFailure(
          messageAr: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
          messageEn: 'An unexpected error occurred.',
          errorCode: 'UNKNOWN',
        );
    }
  }

  Failure _fromResponse(Response? response) {
    if (response == null) {
      return const ApiFailure(
        messageAr: 'لا توجد استجابة من الخادم.',
        messageEn: 'No response from server.',
        errorCode: 'NO_RESPONSE',
        statusCode: 0,
      );
    }

    final status = response.statusCode ?? 0;
    final body = response.data;

    // The real API envelope only sends a top-level `message` string.
    String? message;
    if (body is Map<String, dynamic>) {
      message = body['message'] as String?;
    }

    return ApiFailure(
      messageAr: message ?? _defaultArMessage(status),
      statusCode: status,
    );
  }

  String _defaultArMessage(int status) => switch (status) {
    400 => 'طلب غير صحيح. تحقق من البيانات المدخلة.',
    401 => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
    403 => 'ليس لديك صلاحية للوصول.',
    404 => 'المورد المطلوب غير موجود.',
    409 => 'هذا الحساب موجود بالفعل.',
    422 => 'بيانات غير صالحة.',
    429 => 'طلبات كثيرة. أعد المحاولة لاحقاً.',
    500 => 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
    _ => 'حدث خطأ ($status). يرجى المحاولة مرة أخرى.',
  };
}
