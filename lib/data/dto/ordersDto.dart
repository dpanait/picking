import 'package:piking/domain/model/internal_note.dart';
import 'package:piking/domain/model/orders.dart';

class OrdersDto extends Orders {
  OrdersDto(
      {super.ordersId, //
      super.ordersSku,
      super.datePurchased,
      super.ordersTypeId,
      super.IDCLIENTE,
      super.enviosEstadosId,
      super.cajasId,
      super.city,
      super.postcode,
      required super.totalBox,
      required super.totalPack,
      required super.totalUd,
      required super.userPicking,
      required super.internalNotes});
  factory OrdersDto.fromJson(Map<String, dynamic> json) {
    List<InternalNotes> internalNotes = [];
    if (json['iternal_notes'] is List) {
      json['internal_notes'].forEach((js) {
        internalNotes.add(InternalNotes.fromJson(js));
      });
    }

    return OrdersDto(
        ordersId: json['orders_id'], //
        ordersSku: json['orders_sku'] ?? "",
        datePurchased: json['date_purchased'] ?? "",
        ordersTypeId: json['orders_type_id'] ?? "",
        IDCLIENTE: json['IDCLIENTE'],
        enviosEstadosId: json['envios_estados_id'],
        cajasId: json['orders_id'],
        city: json['city'] ?? "",
        postcode: json['postcode'] ?? "",
        totalBox: json['total_box'],
        totalPack: json['total_pack'],
        totalUd: json['total_ud'],
        userPicking: json['picking_code'],
        internalNotes: internalNotes);
  }

  @override
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
    data['total_box'] = totalBox;
    data['total_pack'] = totalPack;
    data['totals_ud'] = totalUd;
    data['picking_code'] = userPicking;
    return data;
  }
}
