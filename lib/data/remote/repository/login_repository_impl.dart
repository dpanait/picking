import 'package:piking/data/remote/model/login_response.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/repository/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final Api _apiInstance;
  LoginRepositoryImpl(this._apiInstance);

  @override
  Future<LoginResponse> login(String code1, String code2, String code3) async {
    return await _apiInstance.login(code1, code2, code3);
  }

  @override
  Future<String> getVersion() {
    return _apiInstance.getVersion();
  }
}
