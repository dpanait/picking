import 'dart:developer';

import 'package:mockito/mockito.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_response_entity.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';

 class MockProductsLocationProvider extends Mock
    implements ProductsLocationProvider {

      late LocationResponseEntity locationsReponse = LocationResponseEntity.empty();
      
        set _showPopup(bool _showPopup) {}
      
        set _showButton(bool _showButton) {}
      
        set _isLoading(bool _isLoading) {}
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
      notifyListeners();

      } catch(e, stackTrace) {
      log("Error exception http: $e");
      log("Error details: $stackTrace");

    }
  }
}

// // En tu test
// test('updates selectedLocationObj on successful dialog close', () async {
//   // ...
//   final productsLocationProviderMock = MockProductsLocationProvider();

//   // Configurar el comportamiento del mock
//   when(productsLocationProviderMock.changeLocation(any)).thenAnswer((_) async {
//     // Aquí puedes simular el comportamiento real o simplemente verificar que se llamó
//     print('changeLocation fue llamado');
//   });

//   // ... resto de tu test
// });

