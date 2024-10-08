import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_response_entity.dart';
import 'package:piking/feature/stock/data/remote/model/products_multi_ean_model.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:piking/feature/stock/domain/repository/store_repository.dart';

class ProductsLocationProvider extends ChangeNotifier {

  bool _showButton = false;
  bool _showPopup = false;
  bool _isLoading = false;
  // get 
  bool get showButton => _showButton;
  bool get showPopup => _showPopup;
  bool get isLoading => _isLoading;
  // set
  set showButton(bool value){
    _showButton = value;
    notifyListeners();
  }
  set showPopup(bool value){
    _showPopup = value;
    notifyListeners();
  }
  set isLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }


  late LocationResponseEntity locationsReponse = LocationResponseEntity.empty();
  List<ProductsMultiEan> productsMultiEanList = [];
  List<StoreEntity> stores = [];
  var productsLocationRepository = di.get<ProductsLocationRepository>();
  var storeRepository = di.get<StoreRepository>();

  //var productsLocationLocalRepository = di.get<ProductsLocationLocalRepository>();
  
  Future<void> locationEan(String ean, int productsId) async {
    if(ean.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try{
      //if(ean != ""){
        ProductsLocationResponseEntity resultLocationEan = await productsLocationRepository.locationEan(ean, productsId);
        if (resultLocationEan.type != "") {

          locationsReponse = resultLocationEan.locationResponse;
          productsMultiEanList = resultLocationEan.productsMultiEan;
          _showButton = false;
          _showPopup = false;
          notifyListeners();
          if(locationsReponse.locationOrigin.productsLocations!.isNotEmpty){
            _showButton = true;
            _isLoading = false;
            notifyListeners();
          }
          if(productsMultiEanList.isNotEmpty){
            _showPopup = true;
            _isLoading = false;
            notifyListeners();
          }
          
        } else {
          _showButton = false;
          _showPopup = false;
          _isLoading = false;
          productsMultiEanList.clear();
          notifyListeners();
        }
      ///}

      /*if(productsId != ""){
        ProductsLocationResponse resultLocationEan = await productsLocationRepository.locationProduct(productsId);
        log("resultLocationEan: ${resultLocationEan.locationResponse.locationOrigin.productsLocations.length} - ${resultLocationEan.type}");
        if (resultLocationEan.type != "") {

          locationsReponse = resultLocationEan.locationResponse;
          productsMultiEanList = resultLocationEan.productsMultiEan;
          showButton = false;
          showPopup = false;

          if(locationsReponse.locationOrigin.productsLocations.isNotEmpty){
            showButton = true;
          }
          if(productsMultiEanList.isNotEmpty){
            showPopup = true;
          }
          
        } else {
          showButton = false;
          showPopup = false;
          productsMultiEanList.clear();
        }
      }*/
      
      notifyListeners();
       
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");

    }
  }
  Future<void> moveToZero(BuildContext context, SelectedLocation selectedLocation) async {

    log("slectedLocation: ${SelectedLocation.toJson(selectedLocation)}");
    try{
      bool result = await productsLocationRepository.moveToZero(selectedLocation);
      if(!result){

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: const Text('Error: Algo salió mal'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () {
                // Acción a realizar al presionar el botón
              },
            ),
          ),
        );
      }
      notifyListeners();
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
  Future<void> moveToZeroUnlink(SelectedLocation selectedLocation) async {

    log("slectedLocation: ${SelectedLocation.toJson(selectedLocation)}");
    try{
      await productsLocationRepository.moveToZeroUnlink(selectedLocation);
      notifyListeners();
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
  Future<void> makeFavoriteLocation(SelectedLocation selectedLocation, String note) async {

    log("slectedLocation: ${SelectedLocation.toJson(selectedLocation)} - $note");
    try{
      await productsLocationRepository.makeFavoriteLocation(selectedLocation, note);
      notifyListeners();
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
  Future<void> getStore() async {
    try{
      stores = await storeRepository.getStore();
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
  Future<void> changeLocation(SelectedLocation selectedLocation) async {

    log("slectedLocation: ${SelectedLocation.toJson(selectedLocation)}");
    try{
      await productsLocationRepository.changeLocation(selectedLocation);
      notifyListeners();
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");
    }
  }
}