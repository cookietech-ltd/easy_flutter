
import 'base_exception.dart';

enum NetworkErrorType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badResponse,
  cancel,
  connectionError,
  unknown
}

class NetworkException extends BaseException {
  final int? statusCode;
  final String? errorBody;
  final Uri? requestUrl;
  final NetworkErrorType type;
  final dynamic dioErrorType;
  final Map<String, dynamic>? headers;
  final dynamic rawData;

  NetworkException({
    required String message,
    this.statusCode,
    this.errorBody,
    this.requestUrl,
    this.type = NetworkErrorType.unknown,
    this.dioErrorType,
    this.headers,
    this.rawData,
  }) : super(message: message);

// factory NetworkException.fromDioException(DioException error) {
//     NetworkErrorType type;
//     String message;
//
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//         type = NetworkErrorType.connectionTimeout;
//         message = 'Connection timeout';
//         break;
//       case DioExceptionType.sendTimeout:
//         type = NetworkErrorType.sendTimeout;
//         message = 'Send timeout';
//         break;
//       case DioExceptionType.receiveTimeout:
//         type = NetworkErrorType.receiveTimeout;
//         message = 'Receive timeout';
//         break;
//       case DioExceptionType.badResponse:
//         type = NetworkErrorType.badResponse;
//         message = _handleStatusCode(error.response?.statusCode);
//         break;
//       case DioExceptionType.cancel:
//         type = NetworkErrorType.cancel;
//         message = 'Request cancelled';
//         break;
//       case DioExceptionType.connectionError:
//         type = NetworkErrorType.connectionError;
//         message = 'Connection error';
//         break;
//       case DioExceptionType.unknown:
//         if (error.error is String) {
//           message = error.error.toString();
//         } else {
//           message = 'Unknown error occurred';
//         }
//         type = NetworkErrorType.unknown;
//         break;
//       default:
//         message = 'Unknown error occurred';
//         type = NetworkErrorType.unknown;
//     }
//
//     return NetworkException(
//       message: message,
//       statusCode: error.response?.statusCode,
//       errorBody: error.response?.data?.toString(),
//       requestUrl: error.requestOptions.uri,
//       type: type,
//       dioErrorType: error.type,
//       headers: error.response?.headers.map,
//       rawData: error.response?.data,
//     );
//   }
//
//   ErrorResponse? get errorResponse {
//     try {
//       if (rawData == null) return null;
//
//       // Handle Map data
//       if (rawData is Map<String, dynamic>) {
//         return ErrorResponse.fromJson(rawData);
//       }
//
//       // Handle String data
//       if (rawData is String) {
//         try {
//           final jsonData = json.decode(rawData as String);
//           if (jsonData is Map<String, dynamic>) {
//             return ErrorResponse.fromJson(jsonData);
//           }
//         } catch (_) {
//           // If JSON parsing fails, create a basic error response
//           return ErrorResponse(
//             message: rawData as String,
//             statusCode: statusCode,
//           );
//         }
//       }
//
//       // If rawData is already an ErrorResponse
//       if (rawData is ErrorResponse) {
//         return rawData as ErrorResponse;
//       }
//
//       // If we can't handle the data format, create a default error response
//       return ErrorResponse(
//         message: message,
//         statusCode: statusCode,
//       );
//     } catch (e) {
//       // Fallback error response with the original exception message
//       return ErrorResponse(
//         message: message,
//         statusCode: statusCode ?? 0,
//       );
//     }
//   }
//
//   static String _handleStatusCode(int? statusCode) {
//     switch (statusCode) {
//       case 400:
//         return 'Bad request';
//       case 401:
//         return 'Unauthorized';
//       case 403:
//         return 'Forbidden';
//       case 404:
//         return 'Not found';
//       case 408:
//         return 'Request timeout';
//       case 500:
//         return 'Internal server error';
//       case 502:
//         return 'Bad gateway';
//       case 503:
//         return 'Service unavailable';
//       case 504:
//         return 'Gateway timeout';
//       default:
//         return 'HTTP error occurred';
//     }
//   }
//
//   @override
//   String toString() {
//     final details = <String>[];
//     if (statusCode != null) details.add('Status: $statusCode');
//     if (requestUrl != null) details.add('URL: $requestUrl');
//     if (type != NetworkErrorType.unknown) details.add('Type: $type');
//     if (errorBody != null && errorBody!.isNotEmpty) {
//       final truncatedBody = errorBody!.length > 100
//           ? '${errorBody!.substring(0, 100)}...'
//           : errorBody!;
//       details.add('Body: $truncatedBody');
//     }
//
//     final detailsString = details.isEmpty ? '' : ' (${details.join(', ')})';
//     return 'NetworkException: $message$detailsString';
//   }
//
//   bool get isServerError => statusCode != null && statusCode! >= 500;
//
//   bool get isClientError =>
//       statusCode != null && statusCode! >= 400 && statusCode! < 500;
//
//   bool get isConnectionError => type == NetworkErrorType.connectionError;
//
//   bool get isTimeoutError =>
//       type == NetworkErrorType.connectionTimeout ||
//       type == NetworkErrorType.receiveTimeout ||
//       type == NetworkErrorType.sendTimeout;
}
