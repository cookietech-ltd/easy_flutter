import 'package:easy_flutter/easy_flutter.dart';

class CoreInitializer implements Initializer {
  @override
  Future<void> init() async {
    // Register Storage Service
    // getIt.registerLazySingleton<StorageService>(
    //   () => SharedPrefsStorageService(),
    // );
    //
    // getIt.registerSingletonAsync<SessionService>(
    //   () => SessionManager.create(storage: getIt<StorageService>()),
    // );
  }
}
