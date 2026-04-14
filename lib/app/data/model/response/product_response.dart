import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';

class ProductResponse {
  final int id;
  final String name;
  final double price;

  const ProductResponse({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(id: id, name: name, price: price);
  }
}
