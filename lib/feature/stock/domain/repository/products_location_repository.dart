import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/data/remote/response/products_location_response.dart';

abstract class ProductsLocationRepository{
  Future<ProductsLocationResponse> locationEan(String ean, int productsId);
  Future<ProductsLocationResponse> locationProduct(String productsId);
  Future<bool> moveToLocation(SelectedLocation selectedLocation);
  Future<bool> moveToZero(SelectedLocation selectedLocation);
  Future<bool> moveToZeroUnlink(SelectedLocation selectedLocation);
  Future<bool> makeFavoriteLocation(SelectedLocation selectedLocation, String note);
  Future<bool> changeLocation(SelectedLocation selectedLocation);
}