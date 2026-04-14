import 'package:easy_flutter/easy_flutter.dart';

class ConnectivityException extends BaseException {
  ConnectivityException()
      : super(
          title: 'No Internet',
          message:
              'No internet connection. Please check your connectivity and try again.',
        );
}
