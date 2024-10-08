import 'dart:convert';
import 'dart:developer';

class ProductsLocation {
  late int locationsProductsId;
  late int productsId;
  late String productsSku;
  late int quantity;
  late int cajasId;
  late String productsName;
  late int productsQuantity;
  late int located;
  late int locationsFavorite;
  late String reference;
  late int locationsId;
  late String location;
  late int cajasAlias;
  late String cajasName;
  late int quantityMax;
  late String image;
  late int udsPack;
  late int udsBox;

  ProductsLocation(
      {required this.locationsProductsId,
      required this.productsId, //
      required this.productsSku,
      required this.quantity,
      required this.cajasId,
      required this.productsName,
      required this.productsQuantity,
      required this.located,
      required this.locationsFavorite,
      required this.reference,
      required this.locationsId,
      required this.location,
      required this.cajasAlias,
      required this.cajasName,
      required this.quantityMax,
      required this.image,
      required this.udsPack,
      required this.udsBox});

  ProductsLocation.fromJson(Map<String, dynamic> json) {
    locationsProductsId = int.parse(json['locations_products_id']).toInt();
    productsId = int.parse(json['products_id']).toInt();
    productsSku = json['products_sku'] ?? "";
    quantity = int.parse(json['quantity']);
    cajasId = int.parse(json['cajas_id']);
    productsName = json['products_name'] ?? "";
    productsQuantity = int.parse(json['products_quantity']);
    located = int.parse(json['located']);
    locationsFavorite = int.parse(json['locations_favorite']);
    reference = json['reference'] ?? "";
    locationsId = int.parse(json['locations_id']);
    location = json['location'] ?? "";
    cajasAlias = int.parse(json['cajas_alias']);
    cajasName = json['cajas_name'] ?? "";
    quantityMax = int.tryParse(json['quantity_max'].toString()) ?? 0;
    image = json['image'];
    //log("uds_pck: ${json['uds_pack']}");
    if( json['uds_pack'] is int){
      udsPack = json['uds_pack'];
    }
    if( json['uds_pack'] is String){
      udsPack =  int.tryParse(json['uds_pack'].toString())!;
    }
    if( json['uds_box'] is int){
      udsBox = json['uds_box'];
    }
    if( json['uds_box'] is String){
      udsBox =  int.tryParse(json['uds_box'].toString())!;
    }
    //udsPack = json['uds_pack'] ?? int.tryParse(json['uds_pack'].toString());
    //udsBox = json['uds_box'] ?? int.tryParse(json['uds_box']);
  }

  static String toJson(ProductsLocation productsLocation) {
    return jsonEncode({
      'locations_products_id': productsLocation.locationsProductsId,
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
      'location': productsLocation.location,
      'cajas_alias': productsLocation.cajasAlias,
      'cajas_name': productsLocation.cajasName,
      'quantity_max': productsLocation.quantityMax,
      'image': productsLocation.image,
      'uds_pack': productsLocation.udsPack,
      'uds_box': productsLocation.udsBox
    });
  }

  static empty() {
    return ProductsLocation(
        locationsProductsId: 0,
        productsId: 0, //
        productsSku: "",
        quantity: 0,
        cajasId: 0,
        productsName: "",
        productsQuantity: 0,
        located: 0,
        locationsFavorite: 0,
        reference: '',
        locationsId: 0,
        location: '',
        cajasAlias: 0,
        cajasName: '',
        quantityMax: 0,
        image: '',
        udsPack: 0,
        udsBox: 0);
  }
}
