import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:piking/domain/response/prducts_location_response.dart';
import 'package:piking/vars.dart';

class LocateStockApi {
  Future<ProductsLocationResponse> validateEan(String ean) async {
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
      return ProductsLocationResponse(status: false, productsLocation: []);
    }
    await getVersion();
    http.Response response;
    try {
      String jsonString = jsonEncode(<String, String>{
          'action': "validate_ean", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'ean': ean
        });
      log("Josn: $jsonString");  
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'action': "validate_ean", //
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'ean': ean
        }),
      );

      log(response.body);
      if (response.statusCode == 200) {
        return ProductsLocationResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return ProductsLocationResponse(status: false, productsLocation: []);
      }
    } catch (e, stackTrace) {
      log("Error exception http: $e");
      log("Error: $stackTrace");
      return ProductsLocationResponse(status: false, productsLocation: []);
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
