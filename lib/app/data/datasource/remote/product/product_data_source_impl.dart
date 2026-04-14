import 'package:easy_flutter_boilerplate/app/data/datasource/remote/product/product_data_source.dart';
import 'package:easy_flutter_boilerplate/app/data/model/response/product_response.dart';

class ProductDataSourceImpl implements ProductDataSource {
  @override
  Future<List<ProductResponse>> getProducts() async {
    // Simulates a network call with mock data.
    await Future<void>.delayed(const Duration(seconds: 1));
    return const [
      ProductResponse(id: 1, name: 'Wireless Headphones', price: 59.99),
      ProductResponse(id: 2, name: 'Mechanical Keyboard', price: 129.99),
      ProductResponse(id: 3, name: 'USB-C Hub', price: 39.99),
      ProductResponse(id: 4, name: 'Monitor Stand', price: 24.99),
      ProductResponse(id: 5, name: 'Laptop Sleeve', price: 19.99),
    ];
  }
}
