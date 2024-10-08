import 'package:piking/domain/model/orders.dart';

abstract class PickingRepository {
  Future<List<Orders>?> getAllPickings(int idCliente, int cajaId);
  Future<void> savePickings();
  Future<Orders> findPickingByOrdersSku(String idcliente, String ordersSku);
}
