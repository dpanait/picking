import 'package:piking/feature/stock/domain/model/stock_entry.dart';

abstract class StockEntryRepository {
  Future<List<StockEntry>> getStockEntryList(int idCliente, int cajasId);
}
