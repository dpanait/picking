import 'dart:convert';

import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';

class ProductsLocation extends ProductsLocationEntity{  

  const ProductsLocation({
    super.productsId,
    super.productsSku,
    super.quantity,
    super.cajasId,
    super.productsName,
    super.productsQuantity,
    super.located,
    super.locationsFavorite,
    super.reference,
    super.locationsId,
    super.cajasAlias,
    super.cajasName,
    super.quantityMax,
    super.image,
    super.multiEan});
  
  factory ProductsLocation.fromJson(Map<String, dynamic> json) {
    return ProductsLocation(
      productsId: int.parse(json['products_id']).toInt(),
      productsSku: json['products_sku'] ?? "",
      quantity: int.parse(json['quantity']),
      cajasId: int.parse(json['cajas_id']),
      productsName: json['products_name'] ?? "",
      productsQuantity: int.parse(json['products_quantity']).toInt(),
      located: int.parse(json['located']),
      locationsFavorite: json['locations_favorite'],
      reference: json['reference'] ?? "",
      locationsId: json['locations_id'],
      cajasAlias: int.parse(json['cajas_alias']),
      cajasName: json['cajas_name'] ?? "",
      quantityMax: json['quantity_max'] ?? 0,
      image: json['image'],
      multiEan: json['multi_ean']
    );
  }
  static String toJson(ProductsLocation productsLocation) {
    return jsonEncode({
      'products_id': productsLocation.productsId,
      'products_sku': productsLocation.productsSku,
      'quantity': productsLocation.quantity,
      'cajas_id': productsLocation.cajasId,
      'products_name': productsLocation.productsName,
      'products_quantity': productsLocation.productsQuantity,
      'located': productsLocation.located,
      'locations_favorite': productsLocation.locationsFavorite,
      'reference': productsLocation.reference,
      'locations_id': productsLocation.locationsId,
      'cajas_alias': productsLocation.cajasAlias,
      'cajas_name': productsLocation.cajasName,
      'quantity_max': productsLocation.quantityMax,
      'image': productsLocation.image,
      'multi_ean': productsLocation.multiEan
    });
  }
  factory ProductsLocation.fromEntity(ProductsLocationEntity entity){
    return ProductsLocation(
      productsId: entity.productsId, 
      productsSku: entity.productsSku, 
      quantity: entity.quantity,
      cajasId: entity.cajasId, 
      productsName: entity.productsName, 
      productsQuantity: entity.productsQuantity, 
      located: entity.located, 
      locationsFavorite: entity.locationsFavorite, 
      reference: entity.reference, 
      locationsId: entity.locationsId, 
      cajasAlias: entity.cajasAlias, 
      cajasName: entity.cajasName, 
      quantityMax: entity.quantityMax, 
      image: entity.image, 
      multiEan: entity.multiEan
    );
  }
  static empty() {
    return const ProductsLocation(
        productsId: 0, //
        productsSku: "",
        quantity: 0,
        cajasId: 0,
        productsName: "",
        productsQuantity: 0,
        located: 0,
        locationsFavorite: "",
        reference: '',
        locationsId: 0,
        cajasAlias: 0,
        cajasName: '',
        quantityMax: 0,
        image: '',
        multiEan: false);
  }
}