import '../errors/failure.dart';

/// Functional result type: either a success value [T] or a [Failure].
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    FailureResult() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success() => null,
    FailureResult(:final failure) => failure,
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Result.success(transform(value)),
    FailureResult(:final failure) => Result.failure(failure),
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    FailureResult(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

// ignore: camel_case_types — trailing underscore avoids clash with Failure base class
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
