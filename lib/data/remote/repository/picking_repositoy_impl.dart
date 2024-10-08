import 'package:piking/domain/model/orders.dart';
import 'package:piking/domain/repository/picking_repository.dart';
import 'package:piking/data/remote/utils/api.dart';

class PickingRepositoryImpl implements PickingRepository {
  final Api _apiInstance;

  PickingRepositoryImpl(this._apiInstance);

  @override
  Future<List<Orders>?> getAllPickings(int idCliente, int cajasId) {
    return _apiInstance.getAllPickings(idCliente, cajasId);
  }

  @override
  Future<void> savePickings() {
    // TODO: implement savePickings
    throw UnimplementedError();
  }

  @override
  Future<Orders> findPickingByOrdersSku(String idcliente, String ordersSku) {
    return _apiInstance.findPickingByOrdersSku(idcliente, ordersSku);
  }
}
