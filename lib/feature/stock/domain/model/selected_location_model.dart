import 'dart:convert';

class SelectedLocation{
  late int locationsId;
  late int cajasId;
  late int productsId;
  late int originLocationsId;
  late int quantity;

  SelectedLocation(this.locationsId, this.cajasId, this.productsId, this.originLocationsId, this.quantity);
  static empty(){
    return SelectedLocation(0, 0, 0, 0, 0);
  }
  static String toJson(SelectedLocation selectedLocation){
    return jsonEncode({
      'location_id': selectedLocation.locationsId,
      'cajas_id': selectedLocation.cajasId,
      'products_id': selectedLocation.productsId,
      'origin_locations_id': selectedLocation.originLocationsId,
      'quantity': selectedLocation.quantity
    });
  }
}