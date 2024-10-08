import 'package:piking/feature/stock/data/remote/model/store_model.dart';

class StoreResponse {
  bool status;
  List<Store> body;
  String? post;

  StoreResponse({required this.status, required this.body, this.post});

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
   
    bool status = json['status'];
    List<Store> body = [];
    if (json['body'] != null) {
      body = <Store>[];
      json['body'].forEach((v) {
        body.add(Store.fromJson(v));
      });
    }
    String post = json['post'];

     return StoreResponse(
      status: status,
      body: body,
      post: post
    );
  }
}