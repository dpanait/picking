import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/model/relocate.dart';
import 'package:piking/domain/response/relocate_response.dart';
import 'package:piking/domain/repository/relocate_repository.dart';

class RelocateRepositoryImpl implements RelocateRepository {
  late final Api _apiInstance;
  RelocateRepositoryImpl(this._apiInstance);

  @override
  Future<RelocateResponse> saveRelocate(int idCliente, Relocate relocate) {
    return _apiInstance.saveRelocate(idCliente, relocate);
  }
}
