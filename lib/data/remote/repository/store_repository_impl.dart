import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/data/remote/utils/api.dart';

class StoreRepositoryImpl implements StoreRepository {
  final Api _apiInstance;

  StoreRepositoryImpl(this._apiInstance);

  @override
  Future<StoreResponse> getAllStore(int idCliente) async {
    return await _apiInstance.getAllStore(idCliente);
  }
}
