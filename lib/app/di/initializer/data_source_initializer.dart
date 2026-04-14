import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/data/datasource/remote/product/product_data_source.dart';
import 'package:easy_flutter_boilerplate/app/data/datasource/remote/product/product_data_source_impl.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';

class DataSourceInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<ProductDataSource>(
      () => ProductDataSourceImpl(),
    );
  }
}
