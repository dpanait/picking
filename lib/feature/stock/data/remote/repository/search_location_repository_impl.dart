import 'dart:developer';

import 'package:piking/feature/stock/data/remote/utils/location_api.dart';
import 'package:piking/feature/stock/domain/repository/search_location_repository.dart';
import 'package:piking/feature/stock/domain/response/search_location_response.dart';

class SearchLocationRepositoryImpl implements SearchLocationRepository{

  final LocationApi _apiInstance;
  SearchLocationRepositoryImpl(this._apiInstance);

  @override
  Future<SearchLocationResponse> searchLocation(String query, int cajasId, int productsId) {
    log("SearchLocationRepositoryImpl: $query - $cajasId - $productsId");
    return _apiInstance.searchLocation(query, cajasId, productsId);
  }

}