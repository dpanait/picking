import 'package:piking/domain/model/inventory.dart';

class LocationResponse {
  late bool status;
  late List<Inventory> inventory;
  LocationResponse({required this.status, required this.inventory});
}
