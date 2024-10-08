import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';

abstract class PickingDetailsRepository {
  Future<List<OrdersProducts>> getOrdersProducts(int idCliente, int ordersId, int cajasId);
  Future<void> savePicking(List<OrdersProducts> ordersProducts, String pickingCode);
  Future<void> saveNote(String note, String ordersId);
  Future<void> saveNoteNonePickingCode(String ordersId);
  Future<void> saveWhoOverridePicking(PickingProcess pickingProcess, String whoAdministratorsSku, String whoAdministratorsName);
  Future<void> savePickingIncomplete(String ordersId, String note);
}
