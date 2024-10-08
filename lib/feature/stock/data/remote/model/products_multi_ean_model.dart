import 'dart:convert';

import 'package:piking/feature/stock/data/remote/response/products_origin_response.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_multi_ean_entity.dart';

class ProductsMultiEan extends ProductsMultiEanEntity{

  ProductsMultiEan({
    required super.productsId,
    required super.productsSku,
    required super.eanRef,
    required super.productsName,
    required super.image,
    super.details
  });

  factory ProductsMultiEan.fromJson(Map<String, dynamic> json) {
    return ProductsMultiEan(
      productsId: int.parse(json['products_id']).toInt(),
      productsSku: json['products_sku'] ?? "",
      eanRef: json['ean_ref'] ?? "",
      productsName: json['products_name'] ?? "",
      image: json['image'] ?? "",
      details: LocationResponse.fromJson(json['details'])
    );
   
  }

  static String toJson(ProductsMultiEan productsMultiEan) {
    return jsonEncode({
      'products_id': productsMultiEan.productsId,
      'products_sku': productsMultiEan.productsSku,
      'ean_ref': productsMultiEan.eanRef,
      'products_name': productsMultiEan.productsName,
      'image': productsMultiEan.image
    });
    
  }
  factory ProductsMultiEan.toEntity(ProductsMultiEanEntity productsMultiEanEntity ){
    return ProductsMultiEan(
      productsId: productsMultiEanEntity.productsId,
      productsSku: productsMultiEanEntity.productsSku,
      eanRef: productsMultiEanEntity.eanRef,
      productsName: productsMultiEanEntity.productsName,
      image: productsMultiEanEntity.image,
      details: productsMultiEanEntity.details
    );
  }
  static empty() {
    return ProductsMultiEan(
      productsId: 0, //
      productsSku: "",
      eanRef: "",
      productsName: "",
      image: '',
      details: LocationResponseEntity.empty()
    );
  }
}