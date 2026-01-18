class BaseException implements Exception{
  final String? title;
  final String? message;

  BaseException({this.title, this.message});

  @override
  String toString() {
    return 'BaseException: $message $title';
  }
}