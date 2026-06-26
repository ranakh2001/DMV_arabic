/// Thrown by data sources; caught by repositories and mapped to [Failure].
class ServerException implements Exception {
  const ServerException({
    required this.messageAr,
    this.messageEn,
    this.statusCode,
    this.errorCode,
  });

  final String messageAr;
  final String? messageEn;
  final int? statusCode;
  final String? errorCode;

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
