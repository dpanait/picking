import 'package:piking/domain/model/inventory.dart';

class InventoryDto extends Inventory {
  @override
  // ignore: overridden_fields
  String? location;
  @override
  // ignore: overridden_fields
  String? ean;
  @override
  // ignore: overridden_fields
  String? productsQuantity;

  InventoryDto({super.location, super.ean, super.productsQuantity});
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['ean'] = ean;
    data['quantityProducts'] = productsQuantity;
    return data;
  }

  InventoryDto.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    ean = json['productsEan'];
    productsQuantity = json['quantityProducts'];
  }
}
