class StockEntry {
  String? ordersId;
  String? ordersSku;
  String? datePurchased;
  String? ordersTypeId;
  String? IDCLIENTE;
  String? enviosEstadosId;
  String? cajasId;
  String? city;
  String? postcode;

  StockEntry(
      {this.ordersId, this.ordersSku, this.datePurchased, this.ordersTypeId, this.IDCLIENTE, this.enviosEstadosId, this.cajasId, this.city, this.postcode});

  StockEntry.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'];
    ordersSku = json['orders_sku'];
    datePurchased = json['date_purchased'];
    ordersTypeId = json['orders_type_id'];
    IDCLIENTE = json['IDCLIENTE'];
    enviosEstadosId = json['envios_estados_id'];
    cajasId = json['cajas_id'];
    city = json['city'];
    postcode = json['postcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders_id'] = ordersId;
    data['orders_sku'] = ordersSku;
    data['date_purchased'] = datePurchased;
    data['orders_type_id'] = ordersTypeId;
    data['IDCLIENTE'] = IDCLIENTE;
    data['envios_estados_id'] = enviosEstadosId;
    data['cajas_id'] = cajasId;
    data['city'] = city;
    data['postcode'] = postcode;
    return data;
  }
}
