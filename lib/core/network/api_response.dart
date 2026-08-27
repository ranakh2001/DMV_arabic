/// Models the API envelope: { success, message, data, errors }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Arabic-first user-facing message (the API only sends one message field).
  String get userMessage =>
      message ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
}
