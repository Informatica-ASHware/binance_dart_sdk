import 'package:meta/meta.dart';

/// A sealed class representing the result of an operation.
///
/// It can be either a [Success] containing a value of type [S],
/// or a [Failure] containing an error of type [E].
@immutable
sealed class Result<S, E> {
  /// Base constructor for [Result].
  const Result();

  /// Creates a [Success] result.
  const factory Result.success(S value) = Success<S, E>;

  /// Creates a [Failure] result.
  const factory Result.failure(E error) = Failure<S, E>;

  /// Returns true if the result is a [Success].
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if the result is a [Failure].
  bool get isFailure => this is Failure<S, E>;

  /// Transforms the success value using [onSuccess] or the failure error
  /// using [onFailure].
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  }) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }

  /// Maps the success value using [fn].
  Result<T, E> map<T>(T Function(S value) fn) {
    return switch (this) {
      Success(value: final v) => Result.success(fn(v)),
      Failure(error: final e) => Result.failure(e),
    };
  }

  /// Maps the failure error using [fn].
  Result<S, T> mapError<T>(T Function(E error) fn) {
    return switch (this) {
      Success(value: final v) => Result.success(v),
      Failure(error: final e) => Result.failure(fn(e)),
    };
  }

  /// Chains another operation that returns a [Result].
  Result<T, E> flatMap<T>(Result<T, E> Function(S value) fn) {
    return switch (this) {
      Success(value: final v) => fn(v),
      Failure(error: final e) => Result.failure(e),
    };
  }

  /// Alias for [fold] to support expressive success/failure handling.
  T when<T>({
    required T Function(S value) success,
    required T Function(E error) failure,
  }) =>
      fold(onSuccess: success, onFailure: failure);
}

/// A successful [Result] containing a [value].
final class Success<S, E> extends Result<S, E> {
  /// Creates a [Success] result with the given [value].
  const Success(this.value);

  /// The success value.
  final S value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<S, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A failed [Result] containing an [error].
final class Failure<S, E> extends Result<S, E> {
  /// Creates a [Failure] result with the given [error].
  const Failure(this.error);

  /// The failure error.
  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<S, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
