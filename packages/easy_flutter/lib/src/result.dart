/// Utility class that simplifies handling success and error cases.
///
/// Return a [Result] from a function to indicate success or failure.
///
/// A [Result] is either an [Ok] with a value of type [T]
/// or an [Error] with an [Exception].
///
/// Use [Result.ok] to create a successful result with a value of type [T].
/// Use [Result.error] to create an error result with an [Exception].
///
/// Evaluate the result using pattern matching:
/// ```dart
/// switch (result) {
///   case Ok(value):
///     print(value);
///   case Error(error, stackTrace):
///     print(error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result] with the given [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result] with the given [error] and optional [stackTrace].
  const factory Result.error(Exception error, [StackTrace? stackTrace]) = Error._;

  /// Applies different functions based on the result type.
  R? when<R>({
    required R? Function(T value) onSuccess,
    R? Function(Exception error, StackTrace? stackTrace)? onError,
  }) {
    return switch (this) {
      Ok<T>(:final value) => onSuccess(value),
      Error<T>(:final error, :final stackTrace) => onError?.call(error, stackTrace),
    };
  }

  /// Maps the value inside `Ok`, keeping errors unchanged.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T>(:final value) => Result.ok(transform(value)),
      Error<T>(:final error, :final stackTrace) => Result.error(error, stackTrace),
    };
  }
}

/// A successful [Result] containing a returned [value].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// An error [Result] containing a resulting [error] and an optional [stackTrace].
final class Error<T> extends Result<T> {
  const Error._(this.error, [this.stackTrace]);

  /// The resulting error.
  final Exception error;

  /// Optional stack trace to assist with debugging.
  final StackTrace? stackTrace;

  @override
  String toString() => 'Result<$T>.error($error, stackTrace: $stackTrace)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Error<T> && other.error == error && other.stackTrace == stackTrace);

  @override
  int get hashCode => Object.hash(error, stackTrace);
}
