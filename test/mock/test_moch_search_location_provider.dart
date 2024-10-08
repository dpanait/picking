import 'dart:developer';

import 'package:mockito/mockito.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:piking/feature/stock/domain/response/search_location_response.dart';

 class MockSearchLocationProvider extends Mock
    implements SearchLocationProvider {
 
  List<LocationEntity> locationOld = [
      LocationEntity(
        locationsId: 1, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '1',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
      LocationEntity(
        locationsId: 2, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '2',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
    ];
   List<LocationEntity> results = [
      LocationEntity(
        locationsId: 1, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '1',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
      LocationEntity(
        locationsId: 2, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '2',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
    ];

  Future<void> searchLocation(String query, int cajasId, int productsId) async{
    if (query.isEmpty) return;
    try{
      var _isLoading = true;
      notifyListeners();

      SearchLocationResponse response = await searchLocationRepository.searchLocation(query, cajasId, productsId);
      if(response.status){
        var _results = response.resultSearch;
        _isLoading = false;
        var _showListResult = true;
        notifyListeners();
      } else {
        var _results = [];
        notifyListeners();
      }
     
    } catch(e, stackTrace) {
      var _results = [];
      log("Error exception http: $e");
      log("Error details: $stackTrace");

    } /*finally{
      _isLoading = false;
      notifyListeners();
    }*/
  }
}