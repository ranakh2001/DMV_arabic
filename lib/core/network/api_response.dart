/// Models the API envelope: { success, message, data }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final T? data;
  final String? message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
    );
  }

  /// Arabic-first user-facing message (the API only sends one message field).
  String get userMessage => message ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
}
