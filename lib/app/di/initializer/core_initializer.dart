import 'package:easy_flutter_boilerplate/app/di/initializer/initializer.dart';

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
