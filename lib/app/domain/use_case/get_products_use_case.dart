import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';
import 'package:easy_flutter_boilerplate/app/domain/repository/product_repository.dart';

class GetProductsUseCase extends NoParamUseCase<List<ProductEntity>> {
  final ProductRepository _repository;

  const GetProductsUseCase(this._repository);

  @override
  Future<Result<List<ProductEntity>>> call() {
    return _repository.getProducts();
  }
}
