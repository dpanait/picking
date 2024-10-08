import 'package:piking/data/remote/model/orders_products_response.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';

class PickingDetailsRepositoryImpl implements PickingDetailsRepository {
  final Api _apiInstance;

  PickingDetailsRepositoryImpl(this._apiInstance);

  @override
  Future<List<OrdersProducts>> getOrdersProducts(int idCliente, int ordersId, int cajasId) async {
    OrdersProductsResponse ordersProductsResonse = await _apiInstance.getOrdersProducts(idCliente, ordersId, cajasId);
    return ordersProductsResonse.body;
  }

  @override
  Future<void> savePicking(List<OrdersProducts> ordersProducts, String pickingCode) async {
    _apiInstance.savePicking(ordersProducts, pickingCode);
  }

  @override
  Future<void> saveNote(String note, String ordersId) async {
    _apiInstance.saveNote(note, ordersId);
  }

  @override
  Future<void> saveNoteNonePickingCode(String ordersId) async {
    _apiInstance.saveNoteNonePickingCode(ordersId);
  }

  @override
  Future<void> saveWhoOverridePicking(PickingProcess pickingProcess, String whoAdministratorsSku, String whoAdministratorsName) async {
    _apiInstance.saveWhoOverridePicking(pickingProcess, whoAdministratorsSku, whoAdministratorsName);
  }

  @override
  Future<void> savePickingIncomplete(String ordersId, String note) async {
    _apiInstance.savePickingIncomplete(ordersId, note);
  }
}
