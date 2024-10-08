import 'package:piking/data/dto/inventoryDto.dart';
import 'package:piking/domain/response/inventory_response.dart';

abstract class InventoryRepository {
  Future<InventoryResponse> saveInventory(int idcliente, InventoryDto inventory);
}
