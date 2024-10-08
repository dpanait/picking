import 'package:piking/data/dto/inventoryDto.dart';
import 'package:piking/domain/response/inventory_response.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/repository/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final Api _apiInstance;
  InventoryRepositoryImpl(this._apiInstance);

  @override
  Future<InventoryResponse> saveInventory(int idcliente, InventoryDto inventory) async {
    return _apiInstance.saveInventory(idcliente, inventory);
  }
}
