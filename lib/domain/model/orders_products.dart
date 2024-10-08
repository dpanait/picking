import 'package:equatable/equatable.dart';

class OrdersProducts with EquatableMixin {
  late final String ordersId;
  late final String ordersSku;
  late final String ordersProductsId;
  late final String productsId;
  late final String? productsSku;
  late final String barcode;
  late final String referencia;
  late final String productsName;
  String? productsQuantity;
  late final String image;
  String? piking;
  late String location;
  late String locationId;
  String? quantityProcessed;
  late final String serieLote;
  late String udsPack;
  late String udsBox;
  late String pickingCode;
  late String? stock;

  OrdersProducts(
      {required this.ordersId, //
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
      required this.locationId,
      required this.quantityProcessed,
      required this.serieLote,
      required this.udsPack,
      required this.udsBox,
      required this.pickingCode,
      required this.stock});

  OrdersProducts.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'];
    ordersSku = json['orders_sku'];
    ordersProductsId = json['orders_products_id'];
    productsId = json['products_id'];
    productsSku = json['products_sku'] ?? "";
    barcode = json['barcode'] ?? "";
    referencia = json['referencia'] ?? "";
    productsName = json['products_name'] ?? "";
    productsQuantity = json['products_quantity'];
    image = json['image'] ?? "";
    piking = json['piking'] ?? 0;
    location = json['location'] ?? "";
    locationId = json['location_id'] ?? "";
    quantityProcessed = json['quantityProcessed'] ?? 0;
    serieLote = json['serie_lote'] ?? "";
    udsPack = json['uds_pack'] ?? "";
    udsBox = json['uds_box'] ?? "";
    pickingCode = json['picking_code'] ?? "";
    stock = json['stock'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders_id'] = ordersId;
    data['orders_sku'] = ordersSku;
    data['orders_products_id'] = ordersProductsId;
    data['products_id'] = productsId;
    data['products_sku'] = productsSku;
    data['barcode'] = barcode;
    data['referencia'] = referencia;
    data['products_name'] = productsName;
    data['products_quantity'] = productsQuantity;
    data['image'] = image;
    data['piking'] = piking;
    data['location'] = location;
    data['location_id'] = locationId;
    data['quantityProcessed'] = quantityProcessed;
    data['serie_lote'] = serieLote;
    data['uds_pack'] = udsPack;
    data['uds_box'] = udsBox;
    data['picking_code'] = pickingCode;
    data['stock'] = stock;
    return data;
  }

  OrdersProducts toEmptyData() {
    var bodyProduct = OrdersProducts(
        ordersId: "", //
        ordersSku: "",
        ordersProductsId: "",
        productsId: "",
        productsSku: "",
        barcode: "",
        referencia: "",
        productsName: "",
        productsQuantity: "",
        image: "",
        piking: "",
        location: "",
        locationId: "",
        quantityProcessed: "",
        serieLote: "",
        udsPack: "",
        udsBox: "",
        pickingCode: "",
        stock: "");
    return bodyProduct;
  }

  @override
  List<Object?> get props => [
        ordersId,
        ordersSku,
        ordersProductsId, //
        productsId,
        productsSku,
        barcode,
        referencia,
        productsName,
        productsQuantity,
        image,
        piking,
        location,
        locationId,
        quantityProcessed,
        serieLote,
        udsPack,
        udsBox,
        pickingCode,
        stock
      ];
}
