import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:piking/feature/stock/domain/repository/search_location_repository.dart';
import 'package:piking/feature/stock/domain/response/search_location_response.dart';

class SearchLocationProvider extends ChangeNotifier{
  List<LocationEntity> _results = [];
  bool _isLoading = false;
  bool _showListResult = false;
  bool _statusMove = false;
  String selectedLocation = "";
  int _selectedLocationsId = 0;
  int _selectedProductsId = 0;
  SelectedLocation _selectedLocationObj = SelectedLocation.empty(); 

  // get
  List<LocationEntity> get results => _results;
  bool get isLoading => _isLoading;
  bool get showListResult => _showListResult;
  bool get statusMove => _statusMove;
  int get selectedLocationsId => _selectedLocationsId;
  int get selectedProductsId => _selectedProductsId;
  SelectedLocation get selectedLocationObj => _selectedLocationObj;

  // set
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();

  } 
  set showListResult(bool value) {
    _showListResult = value;
    notifyListeners();

  } 
  set results(List<LocationEntity> resultLocation){
    _results = resultLocation;
    notifyListeners();
  }
  set selectedLocationsId(int value){
    _selectedLocationsId = value;
    notifyListeners();
  }
  set selectedProductsId(int value){
    _selectedProductsId = value;
    notifyListeners();
  }
  set selectedLocationObj(SelectedLocation selectedlocation){
    _selectedLocationObj = selectedlocation;
    notifyListeners();

  }


  var searchLocationRepository = di.get<SearchLocationRepository>();
  var productsLocationRepository = di.get<ProductsLocationRepository>();

  Future<void> searchLocation(String query, int cajasId, int productsId) async{
    if (query.isEmpty) return;
    try{
      _isLoading = true;
      notifyListeners();

      SearchLocationResponse response = await searchLocationRepository.searchLocation(query, cajasId, productsId);
      if(response.status){
        _results = response.resultSearch;
        _isLoading = false;
        _showListResult = true;
        notifyListeners();
      } else {
        _results = [];
        notifyListeners();
      }
     
    } catch(e, stackTrace) {
      _results = [];
      log("Error exception http: $e");
      log("Error details: $stackTrace");

    } /*finally{
      _isLoading = false;
      notifyListeners();
    }*/
  }

  Future<void> moveToLocation( int quantity) async{
    log("quantity: $quantity");
    if(quantity == 0){
      return;
    }
    _selectedLocationObj.quantity = quantity;
    
    try{
      bool statusMove = await productsLocationRepository.moveToLocation(_selectedLocationObj);
      notifyListeners();
    }catch(e, stackTrace){
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
}