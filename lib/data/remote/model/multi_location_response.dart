
import 'package:piking/domain/model/inventory.dart';

class MultiLocationResponse {
  late bool status;
  late String message;
  late List<Inventory> products;

  MultiLocationResponse({required this.status, required this.message, required this.products});
  MultiLocationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['body'];
    if (json['body'] != null) {
      products = <Inventory>[];
      json['body'].forEach((v) {
        products.add(Inventory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['body'] = message;
    if (products.isNotEmpty) {
      data['body'] = products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
