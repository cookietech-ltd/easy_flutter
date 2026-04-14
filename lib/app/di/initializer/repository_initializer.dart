import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/data/datasource/remote/product/product_data_source.dart';
import 'package:easy_flutter_boilerplate/app/data/repository_impl/product_repository_impl.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';
import 'package:easy_flutter_boilerplate/app/domain/repository/product_repository.dart';

class RepositoryInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt<ProductDataSource>()),
    );
  }
}
