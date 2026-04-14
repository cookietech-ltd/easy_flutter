import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';
import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';
import 'package:easy_flutter_boilerplate/app/domain/use_case/get_products_use_case.dart';

class HomeViewModel extends ViewModel {
  late final GetProductsUseCase _getProductsUseCase;
  late final CommandState<List<ProductEntity>> products;

  @override
  void onInit() {
    super.onInit();
    _getProductsUseCase = inject<GetProductsUseCase>();
    products = createCommandState<List<ProductEntity>>();
  }

  Future<void> loadProducts({
    ErrorCallback? onError,
  }) async {
    await products.executeExact(
      action: () async {
        final result = await _getProductsUseCase.call();
        return switch (result) {
          Ok(value: final v) => v,
          Error(error: final e) => throw e,
        };
      },
      onError: onError,
    );
  }
}
