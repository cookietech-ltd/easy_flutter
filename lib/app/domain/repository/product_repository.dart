import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts();
}
