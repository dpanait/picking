import 'package:piking/feature/stock/data/remote/utils/location_api.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:piking/feature/stock/data/remote/response/products_location_response.dart';

class ProductsLocationRepositoryImpl extends ProductsLocationRepository{

  final LocationApi _apiInstance;
  ProductsLocationRepositoryImpl(this._apiInstance);

  @override
  Future<ProductsLocationResponse> locationEan(String ean, int productsId) {
    return _apiInstance.locationEan(ean, productsId);
  }
  
  @override
  Future<ProductsLocationResponse> locationProduct(String productsId) {
    return _apiInstance.locationProduct(productsId);
  }
  
  @override
  Future<bool> moveToLocation(SelectedLocation selectedLocation) {
    return _apiInstance.moveToLocation(selectedLocation);
  }
  
  @override
  Future<bool> moveToZero(SelectedLocation selectedLocation) {
    return _apiInstance.moveToZero(selectedLocation);

  }
  
  @override
  Future<bool> moveToZeroUnlink(SelectedLocation selectedLocation) {
    return _apiInstance.moveToZeroUnlink(selectedLocation);
  }
  
  @override
  Future<bool> makeFavoriteLocation(SelectedLocation selectedLocation, String note) {
    return _apiInstance.makeFavoriteLocation(selectedLocation, note);
  }
  
  @override
  Future<bool> changeLocation(SelectedLocation selectedLocation) {
    return _apiInstance.changeLocation(selectedLocation);
  }
  
}