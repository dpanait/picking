
import 'package:piking/domain/model/product_locations_model.dart';

class ProductsLocationResponse {
  late bool status;
  late List<ProductsLocation> productsLocation = [];

  ProductsLocationResponse({required this.status, required this.productsLocation});

  ProductsLocationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['products_location'] != null) {
      json['products_location'].forEach((item) {
        productsLocation.add(ProductsLocation.fromJson(item));
      });
    } else {
      productsLocation = [];
    }
  }
}
