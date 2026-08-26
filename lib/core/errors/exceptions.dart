/// Thrown by data sources; caught by repositories and mapped to [Failure].
class ServerException implements Exception {
  const ServerException({
    required this.messageAr,
    this.messageEn,
    this.statusCode,
    this.errorCode,
    this.fieldErrors,
  });

  final String messageAr;
  final String? messageEn;
  final int? statusCode;
  final String? errorCode;

  /// Laravel-style per-field validation errors (`{"field": ["message", ...]}`)
  /// from a 422 response, when present. Lets callers distinguish which field
  /// failed instead of only having the flattened top-level [messageAr].
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => 'ServerException($statusCode: $messageAr)';
}

/// Thrown when there is no network connectivity.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No connectivity']);
  final String message;

  @override
  String toString() => 'NetworkException($message)';
}

/// Thrown on secure-storage access failure.
class StorageException implements Exception {
  const StorageException([this.message = 'Storage error']);
  final String message;

  @override
  String toString() => 'StorageException($message)';
}
