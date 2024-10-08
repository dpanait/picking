import 'package:piking/data/remote/utils/locate_stock_api.dart';
import 'package:piking/domain/response/prducts_location_response.dart';
import 'package:piking/feature/stock/domain/response/stock_move_response.dart';
import 'package:piking/domain/repository/products_location_repository.dart';

class ProductsLocationRepositoryImpl implements ProductsLocationRepository {
  final LocateStockApi _apiInstance;
  ProductsLocationRepositoryImpl(this._apiInstance);

  @override
  Future<ProductsLocationResponse> validateEan(String ean) async {
    return _apiInstance.validateEan(ean);
  }
}
