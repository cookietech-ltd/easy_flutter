import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';
import 'package:easy_flutter_boilerplate/app/domain/repository/product_repository.dart';
import 'package:easy_flutter_boilerplate/app/domain/use_case/get_products_use_case.dart';

class UseCaseInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(getIt<ProductRepository>()),
    );
  }
}
