import 'package:piking/domain/model/orders.dart';

class PickingResponse {
  bool? status;
  List<Orders>? body;
  String? post;

  PickingResponse({this.status, this.body, this.post});

  PickingResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['body'] != null) {
      body = <Orders>[];
      json['body'].forEach((v) {
        body!.add(Orders.fromJson(v));
      });
    }
    post = json['post'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    data['post'] = post;
    return data;
  }
}

class PickingResponseUnic {
  late bool status;
  late Orders order;
  PickingResponseUnic({required this.status, required this.order});
  PickingResponseUnic.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    order = Orders.fromJson(json['order']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['order'] = order.toJson();
    return data;
  }
}
