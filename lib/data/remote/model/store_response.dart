class Store {
  String? cajasId;
  String? cajasName;
  String? cajasNameY;
  Store({this.cajasId, this.cajasName, this.cajasNameY});

  Store.fromJson(Map<String, dynamic> json) {
    cajasId = json['cajas_id'];
    cajasName = json['cajas_name'];
    cajasNameY = json["cajas_name_Y"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["cajas_id"] = cajasId;
    data["cajas_name"] = cajasName;
    data["cajas_name_Y"] = cajasNameY;
    return data;
  }
}

class StoreResponse {
  bool? status;
  List<Store>? body;
  String? post;

  StoreResponse({status, body, post});

  StoreResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['body'] != null) {
      body = <Store>[];
      json['body'].forEach((v) {
        body!.add(Store.fromJson(v));
      });
    }
    post = json['post'];
  }
}
