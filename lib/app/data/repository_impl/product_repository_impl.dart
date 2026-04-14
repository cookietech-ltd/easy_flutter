import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/data/datasource/remote/product/product_data_source.dart';
import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';
import 'package:easy_flutter_boilerplate/app/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts() async {
    try {
      final responses = await _dataSource.getProducts();
      final entities = responses.map((r) => r.toEntity()).toList();
      return Result.ok(entities);
    } on Exception catch (e, st) {
      return Result.error(e, st);
    }
  }
}
