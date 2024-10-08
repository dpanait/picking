import 'dart:convert';

import 'package:piking/feature/stock/domain/entities/location_entity.dart';

class  Location extends LocationEntity{

Location({
  required super.locationsId,
  required super.cajasId,
  required super.IDCLIENTE,
  required super.description,
  required super.P,
  required super.R,
  required super.A,
  required super.H,
  required super.Z,
  required super.sortOrder,
  required super.status,
  super.locationsSku,
  super.txtLocation
});
static String toJson(Location location) {
  return jsonEncode({
    'locations_id': location.locationsId,
    'locations_sku': location.locationsSku,
    'cajas_id' : location.cajasId,
    'IDCLIENTE': location.IDCLIENTE,
    'description': location.description,
    'P': location.P,
    'R': location.R,
    'A': location.A,
    'H': location.H,
    'Z': location.Z,
    'txt_locations': location.txtLocation
  });
}
factory Location.toEntity(LocationEntity locationEntity){
  return Location(
    locationsId: locationEntity.locationsId,
    cajasId: locationEntity.cajasId,
    IDCLIENTE: locationEntity.IDCLIENTE,
    description: locationEntity.description,
    P: locationEntity.P,
    R: locationEntity.R,
    A: locationEntity.A,
    H: locationEntity.H,
    Z: locationEntity.Z,
    sortOrder: locationEntity.sortOrder,
    status: locationEntity.status,
    locationsSku: locationEntity.locationsSku,
    txtLocation: locationEntity.txtLocation
  );
}
static empty() {
  return Location(
    locationsId:  0,
    cajasId: 0,
    IDCLIENTE: 0,
    description: '',
    P: '',
    R: '',
    A: '',
    H: '',
    Z: '',
    sortOrder: 0,
    status: 0
  );
}

factory Location.fromJson(Map<String, dynamic> json) {
  String txtLocation = "";
  String locationsSku = "";
  if(json['locations_sku'] != null){
    locationsSku = json['locations_sku'];
  }
  if(json['txt_location'] != null){
    txtLocation = json['txt_location'];
  }
  return Location(
    locationsId: int.parse(json['locations_id']).toInt(),
    IDCLIENTE: int.parse(json['IDCLIENTE']).toInt(),
    cajasId: int.parse(json['cajas_id']).toInt(),
    description: json['description'],
    P: json['P'],
    R: json['R'],
    A: json['A'],
    H: json['H'],
    Z: json['Z'],
    sortOrder: int.parse(json['sort_order']).toInt(),
    status:  int.parse(json['status']).toInt(),
    locationsSku: locationsSku,
    txtLocation: txtLocation
  );
}

}