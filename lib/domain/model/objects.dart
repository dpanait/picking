// objecto SerieLotes

class SerieLotes {
  late String ordersProductsId;
  late List<SerieLoteItem> serieLoteItem;
  SerieLotes({required this.ordersProductsId, required this.serieLoteItem});

  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders_products_id'] = ordersProductsId;
    data['serie_lote_item'] = serieLoteItem;
    return data;
  }
}

class SerieLoteItem {
  late String serieLoteGroup;
  late String serieLote;
  late int quantity;
  late String date;
  SerieLoteItem(this.serieLoteGroup, this.serieLote, this.quantity, this.date);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serieLoteGroup'] = serieLoteGroup;
    data['quantity'] = quantity;
    data['serieLote'] = serieLote;
    data['date'] = date;

    return data;
  }
}

class SerieLoteList {
  late final List<SerieLotes> serieLoteList;
  SerieLoteList({required this.serieLoteList});
  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serie_lote_list'] = serieLoteList;
    return data;
  }
}
