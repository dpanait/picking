import 'package:piking/feature/stock/domain/response/search_location_response.dart';

abstract class SearchLocationRepository{
  Future<SearchLocationResponse> searchLocation(String query, int cajasId, int productsId);
}