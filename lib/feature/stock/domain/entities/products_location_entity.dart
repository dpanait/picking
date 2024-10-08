import 'package:equatable/equatable.dart';

class ProductsLocationEntity extends Equatable{
  final int? productsId;
  final String? productsSku;
  final int? quantity;
  final int? cajasId;
  final String? productsName;
  final int? productsQuantity;
  final int? located;
  final String? locationsFavorite;
  final String? reference;
  final int? locationsId;
  final int? cajasAlias;
  final String? cajasName;
  final int? quantityMax;
  final String? image;
  final bool? multiEan;

  const ProductsLocationEntity({
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
    required this.cajasAlias,
    required this.cajasName,
    required this.quantityMax,
    required this.image,
    required this.multiEan});
    
    @override
    // TODO: implement props
    List<Object?> get props {
      return[
        productsId, //
        productsSku,
        quantity,
        cajasId,
        productsName,
        productsQuantity,
        located,
        locationsFavorite,
        reference,
        locationsId,
        cajasAlias,
        cajasName,
        quantityMax,
        image,
        multiEan
      ];
    }
}