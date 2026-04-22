import 'package:meta/meta.dart';

/// A sealed class representing the result of an operation.
///
/// It can be either a [Success] containing a value of type [S],
/// or a [Failure] containing an error of type [E].
@immutable
sealed class Result<S, E> {
  const Result();

  /// Creates a [Success] result.
  const factory Result.success(S value) = Success<S, E>;

  /// Creates a [Failure] result.
  const factory Result.failure(E error) = Failure<S, E>;

  /// Returns true if the result is a [Success].
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if the result is a [Failure].
  bool get isFailure => this is Failure<S, E>;

  /// Transforms the success value using [onSuccess] or the failure error using [onFailure].
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  }) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }
}

/// A successful [Result] containing a [value].
final class Success<S, E> extends Result<S, E> {
  /// The success value.
  final S value;

  /// Creates a [Success] result with the given [value].
  const Success(this.value);

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
  /// The failure error.
  final E error;

  /// Creates a [Failure] result with the given [error].
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<S, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
