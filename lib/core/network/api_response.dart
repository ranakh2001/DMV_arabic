/// Models the SRS API envelope:
/// { success, data, message, timestamp, error: { code, message_ar, message_en } }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
    this.error,
  });

  final bool success;
  final T? data;
  final String? message;
  final String? timestamp;
  final ApiError? error;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      error: json['error'] == null
          ? null
          : ApiError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }
}

/// Error object nested in the API envelope.
class ApiError {
  const ApiError({required this.code, this.messageAr, this.messageEn});

  final String code;
  final String? messageAr;
  final String? messageEn;

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String? ?? 'UNKNOWN',
        messageAr: json['message_ar'] as String?,
        messageEn: json['message_en'] as String?,
      );

  /// Arabic-first user-facing message.
  String get userMessage =>
      messageAr ??
      messageEn ??
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
}
