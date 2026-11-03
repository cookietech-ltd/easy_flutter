/// Base exception class for structured error handling across app layers.
///
/// Extend this to create domain-specific exceptions (e.g. NetworkException).
class BaseException implements Exception {
  /// Short heading for the error, e.g. for a dialog title.
  final String? title;

  /// Human-readable description of the error.
  final String? message;

  const BaseException({this.title, this.message});

  @override
  String toString() => 'BaseException: $message $title';
}
