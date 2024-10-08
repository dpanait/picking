import 'package:equatable/equatable.dart';

class Product with EquatableMixin {
  String? ordersId;
  String? ordersSku;
  String? ordersProductsId;
  String? productsId;
  String? productsSku;
  String? barcode;
  String? referencia;
  String? productsName;
  String? productsQuantity;
  String? image;
  String? piking;
  String? location;
  String? quantityProcessed;
  String? serieLote;
  String udsBox;
  String udsPack;

  Product(
      {required this.ordersId,
      required this.ordersSku,
      required this.ordersProductsId,
      required this.productsId,
      required this.productsSku,
      required this.barcode,
      required this.referencia,
      required this.productsName,
      required this.productsQuantity,
      required this.image,
      required this.piking,
      required this.location,
      required this.quantityProcessed,
      required this.serieLote,
      required this.udsBox,
      required this.udsPack});

  @override
  // TODO: implement props
  List<Object?> get props => [
        ordersId, //
        ordersSku,
        ordersProductsId,
        productsId,
        productsSku,
        barcode,
        referencia,
        productsName,
        productsQuantity,
        image,
        piking,
        location,
        quantityProcessed,
        serieLote,
        udsBox,
        udsPack
      ];
}
