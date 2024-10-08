import 'package:piking/domain/model/orders_products.dart';

class OrdersProductsResponse {
  late bool status;
  late List<OrdersProducts> body;
  //late List<OrdersProducts> copyProducts;
  late String post;

  OrdersProductsResponse({required this.status, required this.body, required this.post});

  OrdersProductsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['body'] != null) {
      body = <OrdersProducts>[];
      json['body'].forEach((v) {
        body.add(OrdersProducts.fromJson(v));
      });
    }
    // if (json['copy'] != null) {
    //   copyProducts = <OrdersProducts>[];
    //   json['copy'].forEach((v) {
    //     copyProducts.add(OrdersProducts.fromJson(v));
    //   });
    // }
    post = json['post'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (body.isNotEmpty) {
      data['body'] = body.map((v) => v.toJson()).toList();
    }
    // if (copyProducts.isNotEmpty) {
    //   data['copy'] = copyProducts.map((v) => v.toJson()).toList();
    // }
    data['post'] = post;
    return data;
  }
}
