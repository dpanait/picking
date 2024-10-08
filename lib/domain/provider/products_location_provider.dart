import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:piking/domain/entity/products_location_entity.dart';
import 'package:piking/domain/model/product_locations_model.dart';
import 'package:piking/domain/repository/products_location_local_repository.dart';
import 'package:piking/domain/repository/products_location_repository.dart';
import 'package:piking/domain/response/prducts_location_response.dart';
import 'package:piking/domain/transformer/products_location_transformer.dart';
import 'package:piking/injection_container.dart';

class ProductsLocationProviderOld extends ChangeNotifier {
  bool showNavegation = false;
  List<ProductsLocation> productsLocationsList = [];
  List<ProductsLocationEntity> productsLocationEntityList = [];

  var productsLocationRepository = di.get<ProductsLocationRepository>();
  var productsLocationLocalRepository = di.get<ProductsLocationLocalRepository>();

  Future<void> validateEan(String ean) async {
    try{
      ProductsLocationResponse resultValidateEan = await productsLocationRepository.validateEan(ean);
      if (resultValidateEan.status) {
        for (ProductsLocation item in resultValidateEan.productsLocation) {
          ProductsLocationEntity? productsLocationEntity = await productsLocationLocalRepository.findProductLocationById(item.locationsProductsId);
          log("productsLocationEntity: ${productsLocationEntity?.locationsProductsId}");
          if (productsLocationEntity?.locationsProductsId == null) {
            try {
              ProductsLocationEntity productsLocationEntity =  ProdcustsLocationTr.toEntity(item);
              log("productsLocationEntity: ${productsLocationEntity.locationsProductsId}");
              await productsLocationLocalRepository.insertProduct(productsLocationEntity);
              productsLocationsList.add(item);
              log("productsLocationsList: ${ProductsLocation.toJson(productsLocationsList[0])}");
            } catch (e, stackTrace) {
              log("Error exception http: $e");
              log("Error: $stackTrace");
            }
          } else {
            productsLocationsList.add(ProdcustsLocationTr.toModel(productsLocationEntity!));
          }
        }
        showNavegation = true;
        //await productsLocationLocalRepository.
        notifyListeners();
      } else {
        showNavegation = false;
        productsLocationsList.clear();
        notifyListeners();
      }
      
    } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");

    }
  }
}
