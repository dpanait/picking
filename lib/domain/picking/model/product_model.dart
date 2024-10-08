class ProductS {
  String? ordersId;
  String? ordersSku;
  String? ordersProductsId;
  int? productsId;
  String? productsSku;
  String? barcode;
  String? referencia;
  String? productsName;
  String? productsQuantity;
  String? image;
  int? piking;
  String? location;
  int? quantityProcessed;
  String? serieLote;

  ProductS({
    this.ordersId,
    this.ordersSku,
    this.ordersProductsId,
    this.productsId,
    this.productsSku,
    this.barcode,
    this.referencia,
    this.productsName,
    this.productsQuantity,
    this.image,
    this.piking,
    this.location,
    this.quantityProcessed,
    this.serieLote,
    required String picking,
  });

  productMap() {
    var mapping = <String, dynamic>{};
    mapping['ordersId'] = ordersId;
    mapping['ordersSku'] = ordersSku!;
    mapping['ordersProductsId'] = ordersProductsId!;
    mapping['productsId'] = productsId!;
    mapping['productsSku'] = productsSku;
    mapping['barcode'] = barcode;
    mapping['referencia'] = referencia;
    mapping['productsName'] = productsName!;
    mapping['productsQuantity'] = productsQuantity!;
    mapping['image'] = image;
    mapping['piking'] = piking;
    mapping['location'] = location!;
    mapping['quantityProcessed'] = quantityProcessed!;
    mapping['serieLote'] = serieLote ?? "";
    return mapping;
  }

  productFromMap(map) {
    var product = ProductS(picking: '');
    product.ordersId = map['iordersId'];
    product.ordersSku = map['ordersSku'];
    product.ordersProductsId = map['ordersProductsId'].toString();
    product.productsId = map['productsId'];
    product.productsSku = map['productsSku'];
    product.barcode = map['barcode'];
    product.referencia = map['referencia'];
    product.productsName = map['productsName'];
    product.productsQuantity = map['productsQuantity'].toString();
    product.image = map['image'];
    product.piking = map['piking'];
    product.location = map['location'];
    product.quantityProcessed = map['quantityProcessed'];
    product.serieLote = map['serieLote'];
    return product;
  }

  factory ProductS.mapToProduct(Map<String, Object?> row) {
    return ProductS(
        ordersId: (row['ordersId'] as int).toString(),
        ordersSku: row['ordersSku'] as String,
        ordersProductsId: (row['ordersProductsId'] as int).toString(),
        productsId: row['productsId'] as int,
        productsSku: row['productsSku'] as String,
        barcode: row['barcode'] as String,
        referencia: row['referencia'] as String?,
        productsName: row['productsName'] as String,
        productsQuantity: (row['productsQuantity'] as int).toString(),
        image: row['image'] as String?,
        picking: (row['piking'] as int).toString(),
        location: row['location'] as String,
        quantityProcessed: row['quantityProcessed'] as int,
        serieLote: row['serieLote'] as String);
  }
}
