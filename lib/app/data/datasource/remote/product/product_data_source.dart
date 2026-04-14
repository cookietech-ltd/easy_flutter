import 'package:easy_flutter_boilerplate/app/data/model/response/product_response.dart';

abstract class ProductDataSource {
  Future<List<ProductResponse>> getProducts();
}
