import 'package:equatable/equatable.dart';

class Inventory with EquatableMixin {
  String? location;
  String? ean;
  String? productsQuantity;

  Inventory({this.location, this.ean, this.productsQuantity});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['ean'] = ean;
    data['quantityProducts'] = productsQuantity;
    return data;
  }

  Inventory.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    ean = json['productsEan'];
    productsQuantity = json['quantityProducts'];
  }

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
