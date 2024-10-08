import 'dart:convert';
import 'dart:developer';

import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/data/remote/model/product_location_model.dart';

class LocationResponse extends LocationResponseEntity{

  LocationResponse({required super.locationOrigin, required super.locationZero});

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    //locationZero = json['location_origin'];
    LocationZero locationZero = LocationZero.empty();
    LocationOrigin locationOrigin = LocationOrigin.empty();

		if (json['location_origin'] != null ) {
      locationOrigin = LocationOrigin.fromJson(json['location_origin']);
      log("LocationOrigin: ${locationOrigin.productsLocations!.length}");
		}

    if(json['location_zero'] != null/* && (json['location_zero'] as List).isNotEmpty*/){
      locationZero = LocationZero.fromJson(json['location_zero']);
    }
    return LocationResponse(
      locationOrigin: locationOrigin,
      locationZero: locationZero
    );
    
  }

  static empty(){
    return LocationResponse(
      locationOrigin: LocationOrigin.empty(),
      locationZero: LocationZero.empty()
    );
  }

}

class LocationZero extends LocationZeroEntity{
  //List<ProductsLocationEntity> locationZero = [];

  LocationZero({required super.locationZero});

  factory LocationZero.fromJson(Map<String, dynamic> json){
    List<ProductsLocationEntity> locationZero = [];
    if (json['products'] != null) {
			//json['location_zero'].forEach((v) { locationZero.add(ProductsLocation.fromJson(v)); });
       locationZero = (json['products'] as List)
          .map((item) => ProductsLocation.fromJson(item))
          .toList();
		} 

    return LocationZero(locationZero: locationZero);
  }
  factory LocationZero.fromEntity(LocationZeroEntity locationZeroEntity){
    return LocationZero(
      locationZero: locationZeroEntity.locationZero
    );
  }
  static empty(){
    return LocationZero(locationZero: []);
  }

}

class LocationOrigin extends LocationOriginEntity {

  LocationOrigin({
    super.productsLocations,
    super.locations,
  });
  
  factory LocationOrigin.fromJson(Map<String, dynamic> json) {
   
    // Mapeo para los productos
   List<ProductsLocationEntity> productsMap = [];
    json['products'].forEach((key, value) {
      //log("Value: $value");
      value.toList().forEach((item){
        productsMap.add(ProductsLocation.fromJson(item));
      });
    });

    // Mapeo para las ubicaciones
    var locationList = List<Location>.from(json['location'].map((item) => Location.fromJson(item)));

    return LocationOrigin(
      productsLocations: productsMap,
      locations: locationList,
    );
  }

  Map<String, dynamic> toJson() {
    // Serialización de productos
    List<ProductsLocation> productsMap = [];
    return {
      'products_locations': productsMap,
      'locations': List<ProductsLocationEntity>.from(locations!.map((item) => Location.toJson(item))),
    };
  }
  factory LocationOrigin.fromEntity(LocationOriginEntity locationOriginEntity){
    return LocationOrigin(
      productsLocations: locationOriginEntity.productsLocations,
      locations: locationOriginEntity.locations
    );
  }

  static empty(){
    return LocationOrigin(
      productsLocations: [],
      locations: []
    );
  }
}

