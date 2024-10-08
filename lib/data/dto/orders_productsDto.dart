class OrdersProductsDto {
  // ignore: prefer_typing_uninitialized_variables
  var ordersId;

  var ordersSku;

  var ordersProductsId;

  var productsId;

  var productsSku;

  var barcode;

  var referencia;

  var productsName;

  var productsQuantity;

  var image;

  var piking;

  var location;

  var quantityProcessed;

  var serieLote;

  OrdersProductsDto(
      {required this.ordersId,
      required this.ordersSku,
      required this.ordersProductsId, //
      required this.productsId,
      this.productsSku,
      required this.barcode,
      required this.referencia,
      required this.productsName,
      required this.productsQuantity,
      required this.image,
      required this.piking,
      required this.location,
      required this.quantityProcessed,
      required this.serieLote});

  factory OrdersProductsDto.fromJson(Map<String, dynamic> json) {
    return OrdersProductsDto(
        ordersId: json['orders_id'],
        ordersSku: json['orders_sku'],
        ordersProductsId: json['orders_products_id'],
        productsId: json['products_id'],
        productsSku: json['products_sku'] ?? "",
        barcode: json['barcode'] ?? "",
        referencia: json['referencia'] ?? "",
        productsName: json['products_name'] ?? "",
        productsQuantity: json['products_quantity'] ?? 0,
        image: json['image'] ?? "",
        piking: json['piking'] ?? 0, //
        location: json['location'] ?? "",
        quantityProcessed: json['quantityProcessed'] ?? 0,
        serieLote: json['serie_lote'] ?? "");
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
    data['quantityProcessed'] = quantityProcessed;
    data['serie_lote'] = serieLote;
    return data;
  }

  //@override
  OrdersProductsDto toEmptyData() {
    var bodyProduct = OrdersProductsDto(
        ordersId: "",
        ordersSku: "",
        ordersProductsId: "",
        productsId: "", //
        productsSku: "",
        barcode: "",
        referencia: "",
        productsName: "",
        productsQuantity: "",
        image: "",
        piking: "",
        location: "",
        quantityProcessed: "",
        serieLote: "");
    return bodyProduct;
  }
}
