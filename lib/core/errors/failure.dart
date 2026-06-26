/// Base class for all domain-layer failures.
abstract class Failure {
  const Failure({required this.messageAr, this.messageEn});

  /// Arabic-first user-facing message.
  final String messageAr;

  /// Optional English fallback.
  final String? messageEn;

  /// Returns Arabic message (default) or English when [arabic] is false.
  String message({bool arabic = true}) =>
      arabic ? messageAr : (messageEn ?? messageAr);

  @override
  String toString() => 'Failure($messageAr)';
}

/// A failure originating from the remote API layer.
class ApiFailure extends Failure {
  const ApiFailure({
    required super.messageAr,
    super.messageEn,
    this.statusCode,
    this.errorCode,
  });

  final int? statusCode;
  final String? errorCode;
}

/// A failure caused by no internet / socket error.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.messageAr = 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وأعد المحاولة.',
    super.messageEn = 'No internet connection. Please check your network.',
  });
}

/// A failure from secure storage read/write.
class StorageFailure extends Failure {
  const StorageFailure({
    super.messageAr = 'خطأ في التخزين الآمن. سيتم تسجيل خروجك تلقائياً.',
    super.messageEn = 'Secure storage error. You will be logged out.',
  });
}

/// Validation failures (client-side).
class ValidationFailure extends Failure {
  const ValidationFailure({required super.messageAr, super.messageEn});
}

/// A feature that is not yet available.
class UnavailableFailure extends Failure {
  const UnavailableFailure({
    super.messageAr = 'هذه الميزة غير متاحة حالياً.',
    super.messageEn = 'This feature is not available yet.',
  });
}
