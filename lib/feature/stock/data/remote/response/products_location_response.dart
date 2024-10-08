import 'package:piking/feature/stock/domain/entities/products_location_response_entity.dart';
import 'package:piking/feature/stock/data/remote/model/products_multi_ean_model.dart';
import 'package:piking/feature/stock/data/remote/response/products_origin_response.dart';

class ProductsLocationResponse extends ProductsLocationResponseEntity {

  ProductsLocationResponse({
    required super.type,
    required super.locationResponse,
    required super.productsMultiEan
  });

  factory ProductsLocationResponse.fromJson(Map<String, dynamic> json) {
    LocationResponse locationResponse = LocationResponse.empty();
    List<ProductsMultiEan> productsMultiEan = [];
    String type = json['type'];

    if(type == 'unico' ){
      if (json['products_location'] != null) {
        locationResponse = LocationResponse.fromJson(json['products_location']);
      }
    }
    if(type == 'multi'){
       if (json['products_location'] != null) {
        json['products_location'].forEach((item) {
          productsMultiEan.add(ProductsMultiEan.fromJson(item));
        });
      } else {
        productsMultiEan = [];
      }
    }
    return ProductsLocationResponse(
        type: type,
        locationResponse: locationResponse,
        productsMultiEan: productsMultiEan
    );
    
  }

  factory ProductsLocationResponse.fromEntity(ProductsLocationResponseEntity productsLocationResponseEntity){
    return ProductsLocationResponse(
      type: productsLocationResponseEntity.type,
      locationResponse: productsLocationResponseEntity.locationResponse,
      productsMultiEan: productsLocationResponseEntity.productsMultiEan
    );
  }
  static empty(){
    return ProductsLocationResponse(
      type: "",
      locationResponse: LocationResponse.empty(),
      productsMultiEan: []
    );
  }
}
