import 'package:piking/data/remote/model/login_response.dart';

abstract class LoginRepository {
  Future<LoginResponse> login(String code1, String code2, String code3);
  Future<String> getVersion();
}
