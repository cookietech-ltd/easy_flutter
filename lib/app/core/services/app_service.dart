import 'package:easy_flutter_boilerplate/app/di/initializer/di_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';

/// Singleton responsible for app-level bootstrap and teardown.
class AppService {
  AppService._internal();

  static final AppService _instance = AppService._internal();

  factory AppService() => _instance;

  /// Initializes all dependency injection layers in order.
  Future<void> start() async {
    await DiInitializer().init();
  }

  /// Resets all registered dependencies and re-initializes the DI graph.
  Future<void> reset() async {
    await getIt.reset();
    await DiInitializer().init();
  }
}
