import 'package:piking/domain/entity/products_location_entity.dart';
import 'package:piking/domain/model/product_locations_model.dart';

class ProdcustsLocationTr {
  ProdcustsLocationTr._();

  static ProductsLocationEntity toEntity(ProductsLocation porductsLocation) {
    return ProductsLocationEntity(
        locationsProductsId: porductsLocation.locationsProductsId,
        produtsId: porductsLocation.productsId, //
        productsSku: porductsLocation.productsSku,
        quantity: porductsLocation.quantity,
        quantityProcessed: 0,
        cajasId: porductsLocation.cajasId,
        productsName: porductsLocation.productsName,
        productsQuantity: porductsLocation.productsQuantity,
        located: porductsLocation.located,
        locationsFavorite: porductsLocation.locationsFavorite,
        reference: porductsLocation.reference,
        locationsId: porductsLocation.locationsId,
        newLocationId: 0,
        location: porductsLocation.location,
        cajasAlias: porductsLocation.cajasAlias,
        cajasName: porductsLocation.cajasName,
        quantityMax: porductsLocation.quantityMax,
        image: porductsLocation.image,
        udsPack: porductsLocation.udsPack,
        udsBox: porductsLocation.udsBox);
  }

  static ProductsLocation toModel(ProductsLocationEntity productsLocationEntity) {
    return ProductsLocation(
        locationsProductsId: productsLocationEntity.locationsProductsId,
        productsId: productsLocationEntity.produtsId,
        productsSku: productsLocationEntity.productsSku,
        quantity: productsLocationEntity.quantity,
        cajasId: productsLocationEntity.cajasId,
        productsName: productsLocationEntity.productsName,
        productsQuantity: productsLocationEntity.productsQuantity,
        located: productsLocationEntity.located,
        locationsFavorite: productsLocationEntity.locationsFavorite,
        reference: productsLocationEntity.reference,
        locationsId: productsLocationEntity.locationsId,
        location: productsLocationEntity.location,
        cajasAlias: productsLocationEntity.cajasAlias,
        cajasName: productsLocationEntity.cajasName,
        quantityMax: productsLocationEntity.quantityMax,
        image: productsLocationEntity.image,
        udsPack: productsLocationEntity.udsPack,
        udsBox: productsLocationEntity.udsBox);
  }
}
