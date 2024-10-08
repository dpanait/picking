import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';
import 'package:piking/feature/stock/data/remote/response/store_response.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/data/remote/response/products_location_response.dart';
import 'package:piking/feature/stock/domain/response/search_location_response.dart';
//import 'package:piking/domain/response/prducts_location_response.dart';
import 'package:piking/vars.dart';

class LocationApi {

  Future<ProductsLocationResponse> locationEan(String ean, int productsId) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return ProductsLocationResponse.empty();
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "location_ean", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'ean': ean,
          'products_id': productsId.toString()
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        return ProductsLocationResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return ProductsLocationResponse.empty();
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return ProductsLocationResponse.empty();
    }
  }
  Future<ProductsLocationResponse> locationProduct(String productsId) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return ProductsLocationResponse.empty();
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "location_ean", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'ean': "",
          'products_id': productsId
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        return ProductsLocationResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return ProductsLocationResponse.empty();
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return ProductsLocationResponse.empty();
    }
  }
  Future<SearchLocationResponse> searchLocation(String query, int cajasId, int productsId) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return SearchLocationResponse.empty();
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "search_location", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'cajas_id': cajasId.toString(),
          'products_id': productsId.toString(),
          'query': query
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        return SearchLocationResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return SearchLocationResponse.empty();
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return SearchLocationResponse.empty();
    }

  }
  Future<bool> moveToLocation(SelectedLocation selectedLocation) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return false;
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "move_to_location", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'locations_id': selectedLocation.locationsId.toString(),
          'cajas_id': selectedLocation.cajasId.toString(),
          'products_id': selectedLocation.productsId.toString(),
          'origin_locations_id': selectedLocation.originLocationsId.toString(),
          'quantity': selectedLocation.quantity.toString()
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        var resultError = jsonDecode(response.body);
        //log("resultError: ${resultError['result']['error']}");
        if(resultError['status'] == false){
          Fluttertoast.showToast(
            msg: resultError['result']['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        }
        return true;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return false;
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return false;
    }
  }
  Future<bool> moveToZero(SelectedLocation selectedLocation) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return false;
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "move_to_zero", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'cajas_id': selectedLocation.cajasId.toString(),
          'products_id': selectedLocation.productsId.toString(),
          'origin_locations_id': selectedLocation.originLocationsId.toString(),
          'quantity': selectedLocation.quantity.toString()
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        var resultError = jsonDecode(response.body);
        //log("resultError: ${resultError['result']['error']}");
        if(resultError['status'] == false){
          Fluttertoast.showToast(
            msg: resultError['result']['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        }
        return true;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return false;
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return false;
    }
  }
  Future<bool> moveToZeroUnlink(SelectedLocation selectedLocation) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return false;
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "move_to_zero_unlink", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'cajas_id': selectedLocation.cajasId.toString(),
          'products_id': selectedLocation.productsId.toString(),
          'origin_locations_id': selectedLocation.originLocationsId.toString()
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        var resultError = jsonDecode(response.body);
        //log("resultError: ${resultError['result']['error']}");
        if(resultError['status'] == false){
          Fluttertoast.showToast(
            msg: resultError['result']['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        }
        return true;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return false;
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return false;
    }
  }
  Future<bool> makeFavoriteLocation(SelectedLocation selectedLocation, String note) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return false;
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "make_favorite_location", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'cajas_id': selectedLocation.cajasId.toString(),
          'products_id': selectedLocation.productsId.toString(),
          'origin_locations_id': selectedLocation.originLocationsId.toString(),
          'comment': note
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        var resultError = jsonDecode(response.body);
        //log("resultError: ${resultError['result']['error']}");
        if(resultError['status'] == false){
          Fluttertoast.showToast(
            msg: resultError['result']['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        }
        return true;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return false;
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return false;
    }
  }
   // buscamos los almacenes del cliente
  Future<StoreResponse> getAllStore() async {
    bool isConnected = await checkInternetConnection();
    String IDCLIENTE =  PickingVars.IDCLIENTE.toString();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return StoreResponse(status: false, body: []);
    }
    await getVersion();
    if (kDebugMode) {
      print("Idcliente $IDCLIENTE");
    }
    if (kDebugMode) {
      print("URL store: ${PickingVars.URL_API}");
    }

    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'action': "almacen", 'idcliente':  IDCLIENTE}),
      );
      if (kDebugMode) {
        print("Store: ${response.body}");
      }
      if (response.statusCode == 200) {
        return StoreResponse.fromJson(json.decode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return StoreResponse(status: false, body: []);
      }
    } catch (e) {
      print("Error: $e");
      return StoreResponse(status: false, body: []);
    }
  }
  Future<bool> changeLocation(SelectedLocation selectedLocation) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return false;
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "change_location", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'locations_id': selectedLocation.locationsId.toString(),
          'cajas_id': selectedLocation.cajasId.toString(),
          'products_id': selectedLocation.productsId.toString(),
          'quantity': selectedLocation.quantity.toString(),
          'origin_locations_id': selectedLocation.originLocationsId.toString(),
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      log(response.body);
      if (response.statusCode == 200) {
        var resultError = jsonDecode(response.body);
        //log("resultError: ${resultError['result']['error']}");
        if(resultError['status'] == false){
          Fluttertoast.showToast(
            msg: resultError['result']['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        }
        
        return true;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        var resultError = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: resultError['result']['error'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
        return false;
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return false;
    }
  }
  
  // get Version
  Future<String> getVersion() async {
    http.Response response;

    try {
      response = await http.get(Uri.parse(PickingVars.URL_VERSION));
      print("getVersion: ${response.body}");
      print("ENVIROMENT: ${PickingVars.ENVIRONMENT}");
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Version: ${PickingVars.VERSION}");
        }
        if (response.body.contains("PAGINA NO DISPONIBLE")) {
          Fluttertoast.showToast(
              msg: "Error: No podemos identificar la version del sistema. Porfavor contacta con el administrador.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 15,
              backgroundColor: const Color.fromARGB(255, 184, 183, 183),
              textColor: const Color.fromARGB(255, 250, 2, 2),
              fontSize: 16.0);
          return "0";
        } else {
          if (PickingVars.ENVIRONMENT == 'pro' && response.body != "Erorr") {
            PickingVars.VERSION = "pro/buy${response.body}";
            PickingVars.URL_API = "https://yuubbb.com/${PickingVars.VERSION}/yuubbbshop/piking_api";
          }
          return response.body;
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${response.reasonPhrase}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            textColor: Colors.white,
            fontSize: 16.0);
        return "0";
      }
    } catch (_) {
      return "Error";
    }
  }

  Future<bool> checkInternetConnection() async {
    bool isConected = await InternetConnectionChecker().hasConnection;
    return isConected;
  }
}
