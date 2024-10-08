class RelocateResponseRemote {
  late bool status;
  int? idcliente;
  String? body;

  RelocateResponseRemote({required this.status, this.idcliente, this.body});

  factory RelocateResponseRemote.fromJson(Map<String, dynamic> json) {
    return RelocateResponseRemote(status: json['status'], idcliente: json['idcliente'], body: json['body']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['body'] = body;
    return data;
  }
}
