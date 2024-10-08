import 'package:equatable/equatable.dart';
import 'package:piking/domain/model/internal_note.dart';

class Orders with EquatableMixin {
  String? ordersId;
  String? ordersSku;
  String? datePurchased;
  String? ordersTypeId;
  String? IDCLIENTE;
  String? enviosEstadosId;
  String? cajasId;
  String? city;
  String? postcode;
  String? weight;
  String? numLine;
  String? dateStart;
  String? dateEnd;
  String? administratorsSku;
  String? picking;
  String? pickingCode;
  String? statusText;
  String? statusColor;
  late int totalBox = 0;
  late int totalPack = 0;
  late int totalUd = 0;
  late String? userPicking;
  late List<InternalNotes> internalNotes = [];

  Orders(
      {this.ordersId, //
      this.ordersSku,
      this.datePurchased,
      this.ordersTypeId,
      this.IDCLIENTE,
      this.enviosEstadosId,
      this.cajasId,
      this.city,
      this.postcode,
      this.weight,
      this.numLine,
      this.dateStart,
      this.dateEnd,
      this.administratorsSku,
      this.picking,
      this.pickingCode,
      this.statusText,
      this.statusColor,
      required this.totalBox,
      required this.totalPack,
      required this.totalUd,
      required this.userPicking,
      required this.internalNotes});

  Orders.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'];
    ordersSku = json['orders_sku'];
    datePurchased = json['date_purchased'];
    ordersTypeId = json['orders_type_id'];
    IDCLIENTE = json['IDCLIENTE'];
    enviosEstadosId = json['envios_estados_id'];
    cajasId = json['cajas_id'];
    city = json['city'];
    postcode = json['postcode'];
    weight = json['weight'];
    numLine = json['num_line'];
    dateStart = json['date_start'];
    dateEnd = json['date_end'];
    administratorsSku = json['administrators_sku'];
    picking = json['picking'];
    pickingCode = json['picking_code'];
    statusText = json['ESTADO'];
    statusColor = json['colorfondo'];
    totalBox = json['total_box'];
    totalPack = json['total_pack'];
    totalUd = json['total_ud'];
    userPicking = json['customers_firstname'];
    if (json['internal_notes'] is List) {
      json['internal_notes'].forEach((js) {
        internalNotes.add(InternalNotes.fromJson(js));
      });
    }
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
    data['weight'] = weight;
    data['num_line'] = numLine;
    data['date_start'] = dateStart;
    data['date_end'] = dateEnd;
    data['administrators_sku'] = administratorsSku;
    data['picking'] = picking;
    data['picking_code'] = pickingCode;
    data['ESTADO'] = statusText;
    data['colorfondo'] = statusColor;
    data['total_box'] = totalBox;
    data['total_pack'] = totalPack;
    data['total_ud'] = totalUd;
    data['customers_firstname'] = userPicking;
    return data;
  }

  static Orders empty() {
    return Orders(
        ordersId: "",
        ordersSku: "",
        datePurchased: "",
        ordersTypeId: "",
        IDCLIENTE: "",
        enviosEstadosId: "",
        cajasId: "",
        city: "",
        postcode: "",
        weight: "",
        numLine: "",
        dateStart: "",
        dateEnd: "",
        administratorsSku: "",
        picking: "",
        pickingCode: "",
        statusText: "",
        statusColor: "",
        totalBox: 0,
        totalPack: 0,
        totalUd: 0,
        userPicking: '',
        internalNotes: []);
  }

  @override
  List<Object?> get props => [
        ordersId, //
        ordersSku,
        datePurchased,
        ordersTypeId,
        IDCLIENTE,
        enviosEstadosId,
        cajasId,
        city,
        postcode
      ];
}
