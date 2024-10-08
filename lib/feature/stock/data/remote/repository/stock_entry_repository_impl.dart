import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/feature/stock/domain/model/stock_entry.dart';
import 'package:piking/feature/stock/domain/repository/stock_entry_repository.dart';

class StockEntryRepositoryImpl implements StockEntryRepository {
  late Api _apiInstance;
  StockEntryRepositoryImpl(this._apiInstance);

  @override
  Future<List<StockEntry>> getStockEntryList(int idCliente, int cajasId) async {
    return await _apiInstance.getStockEntryList(idCliente, cajasId);
  }
}
