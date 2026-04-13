/// Base exception class for structured error handling across app layers.
///
/// Extend this to create domain-specific exceptions (e.g. NetworkException).
class BaseException implements Exception {
  final String? title;
  final String? message;

  const BaseException({this.title, this.message});

  @override
  String toString() => 'BaseException: $message $title';
}
