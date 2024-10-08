class LoginResponse {
  bool status;
  int? idcliente;
  String companyName;
  String userName;
  List<String>? body;

  LoginResponse({required this.status, this.idcliente, required this.companyName, required this.userName, this.body});

  factory LoginResponse.fromJson(dynamic json) {
    //Map<String, dynamic>
    return LoginResponse(
        status: json['status'], //
        idcliente: json['idcliente'],
        companyName: json['company_name'],
        userName: json['user_name'],
        body: json['body'].cast<String>());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['idcliente'] = idcliente;
    data['company_name'] = companyName;
    data['user_name'] = userName;
    data['body'] = body;
    return data;
  }
}
