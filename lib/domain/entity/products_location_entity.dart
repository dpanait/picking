import 'package:floor/floor.dart';

@entity
class ProductsLocationEntity {
  @PrimaryKey()
  late int locationsProductsId;
  late int produtsId;
  late String productsSku;
  late int quantity;
  late int quantityProcessed;
  late int cajasId;
  late String productsName;
  late int productsQuantity;
  late int located;
  late int locationsFavorite;
  late String reference;
  late int locationsId;
  late int newLocationId;
  late String location;
  late int cajasAlias;
  late String cajasName;
  late int quantityMax;
  late String image;
  late int udsPack;
  late int udsBox;

  ProductsLocationEntity(
      {required this.locationsProductsId,
      required this.produtsId, //
      required this.productsSku,
      required this.quantity,
      required this.quantityProcessed,
      required this.cajasId,
      required this.productsName,
      required this.productsQuantity,
      required this.located,
      required this.locationsFavorite,
      required this.reference,
      required this.locationsId,
      required this.newLocationId,
      required this.location,
      required this.cajasAlias,
      required this.cajasName,
      required this.quantityMax,
      required this.image,
      required this.udsPack,
      required this.udsBox});

  static ProductsLocationEntity empty() {
    return ProductsLocationEntity(
        locationsProductsId: 0,
        produtsId: 0, //
        productsSku: "",
        quantity: 0,
        quantityProcessed: 0,
        cajasId: 0,
        productsName: "",
        productsQuantity: 0,
        located: 0,
        locationsFavorite: 0,
        reference: '',
        locationsId: 0,
        newLocationId: 0,
        location: '',
        cajasAlias: 0,
        cajasName: '',
        quantityMax: 0,
        image: '',
        udsPack: 0,
        udsBox: 0);
  }
}
