import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;



/// Service Locator Configuration
// class ServiceLocator {
//   static final _instance = ServiceLocator._internal();
//
//   factory ServiceLocator() => _instance;
//
//   ServiceLocator._internal();
//
//
//
//
//   /// Reset specific dependencies
//   /// Useful when you need to reset only certain dependencies
//   Future<void> resetDependency<T extends Object>() async {
//     if (T == SessionManager) {
//       final authProvider = getIt<SessionManager>();
//       await authProvider
//           .clear(); // Clear credentials when resetting auth provider
//     }
//     await getIt.resetLazySingleton<T>();
//   }
// }

/// Extension to make the service locator more accessible
extension ServiceLocatorExtension on Object {
  /// Get an instance of type [T] from the service locator
  T inject<T extends Object>({String? instanceName}) =>
      getIt.get<T>(instanceName: instanceName);
}

/// Mixin to help with dependency injection in tests
mixin ServiceLocatorMixin {
  /// Register a mock instance for testing
  void registerMock<T extends Object>(T mock) {
    if (getIt.isRegistered<T>()) {
      getIt.unregister<T>();
    }
    getIt.registerSingleton<T>(mock);
  }

  /// Reset all dependencies after tests
  Future<void> resetAll() => getIt.reset();
}
