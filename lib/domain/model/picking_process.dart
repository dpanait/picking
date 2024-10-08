import 'dart:convert';

class PickingProcess {
  late final String ordersId;
  late final String administratorsSku;
  late final String readedProducts;
  late final String readedLocations;
  late final String dateStart;
  late final String dateEnd;
  late final String pickingCode;

  PickingProcess(
      {required this.ordersId,
      required this.administratorsSku,
      required this.readedProducts,
      required this.readedLocations,
      required this.dateStart,
      required this.dateEnd,
      required this.pickingCode});
  PickingProcess.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'];
    administratorsSku = json['administrators_sku'];
    readedProducts = json['readed_products'];
    readedLocations = json['readed_locations'];
    dateStart = json['date_start'];
    dateEnd = json['date_end'];
    pickingCode = json['picking_code'];
  }

  String toJson() {
    /*final Map<String, dynamic> data = <String, dynamic>{};
    data['orders_id'] = ordersId;
    data['administrators_sku'] = administratorsSku;
    data['readed_products'] = readedProducts;
    data['readed_locations'] = readedLocations;
    data['date_start'] = dateStart;
    data['date_end'] = dateEnd;
    data['picking_code'] = pickingCode;
    return data;*/
    return jsonEncode({
      'orders_id': ordersId, //
      'administrators_sku': administratorsSku,
      'readed_products': readedProducts,
      'readed_locations': readedLocations,
      'date_start': dateStart,
      'date_end': dateEnd,
      'picking_code': pickingCode
    });
  }
}

class WhoPickingProcess {
  late final String ordersId;
  late final String administratorsSku;
  late final String administratorsName;
  late final String dateStart;
  WhoPickingProcess({required this.ordersId, required this.administratorsSku, required this.administratorsName, required this.dateStart});
  WhoPickingProcess.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'];
    administratorsSku = json['administrators_sku'];
    administratorsName = json['administrators_name'];
    dateStart = json['date_start'];
  }
}

class WhoTakePicking {
  late final String ordersId;
  late final String administratorsSku;
  late final String administratorsName;
  late final String dateStart;
  late final String dateUpdate;
  WhoTakePicking(
      {required this.ordersId, required this.administratorsSku, required this.administratorsName, required this.dateStart, required this.dateUpdate});
  WhoTakePicking.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'] ?? "";
    administratorsSku = json['administrators_sku'] ?? "";
    administratorsName = json['administrators_name'] ?? "";
    dateStart = json['date_start'] ?? "";
    dateUpdate = json['date_update'] ?? "";
  }
}

//  PS.products_id,
//             PS.products_quantity,
//             PS.plazo,
//             CA.cajas_id,
//             CA.cajas_alias,
//             CA.cajas_name,
//             getLocationsName(LP.locations_id) as location,
//             LP.quantity
class StockLocations {
  late int productsId;
  late int productsQuantity;
  late int cajasId;
  late int cajasAlias;
  late String cajasName;
  late String location;
  late int quantity;
  StockLocations(
      {required this.productsId,
      required this.productsQuantity,
      required this.cajasId,
      required this.cajasAlias,
      required this.cajasName,
      required this.location,
      required this.quantity});
  StockLocations.fromJson(Map<String, dynamic> json) {
    productsId = int.parse(json['products_id']);
    productsQuantity = int.parse(json['products_quantity']);
    cajasId = int.parse(json['cajas_id']);
    cajasAlias = int.parse(json['cajas_alias']);
    cajasName = json['cajas_name'] ?? "";
    location = json['location'] ?? "";
    quantity = int.parse(json['quantity']);
  }
}
