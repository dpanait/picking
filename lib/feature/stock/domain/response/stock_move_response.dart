import 'package:piking/domain/model/picking_process.dart';

class TotalStockResponse {
  late bool status;
  late List<StockLocations> stockLocationsList = [];

  TotalStockResponse({required this.status, required this.stockLocationsList});

  TotalStockResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    (json['stock_locations'] as List).forEach((element) {
      stockLocationsList.add(StockLocations.fromJson(element));
    });
  }
}
