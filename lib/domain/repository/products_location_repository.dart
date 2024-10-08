import 'package:piking/domain/response/prducts_location_response.dart';

abstract class ProductsLocationRepository {
  Future<ProductsLocationResponse> validateEan(String ean);
}
