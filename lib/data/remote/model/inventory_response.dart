class InventoryRemoteResponse {
  late bool status;
  int? idcliente;
  String? body;

  InventoryRemoteResponse({required this.status, this.idcliente, this.body});

  factory InventoryRemoteResponse.fromJson(Map<String, dynamic> json) {
    return InventoryRemoteResponse(
        status: json['status'], //
        idcliente: json['idcliente'],
        body: json['body']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['body'] = body;
    return data;
  }
}
