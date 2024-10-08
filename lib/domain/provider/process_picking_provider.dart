import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/data/remote/model/orders_products_response.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';
import 'package:piking/domain/repository/process_picking_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/vars.dart';

class ProcessPickingProvider extends ChangeNotifier {
  bool whoOwnsPickingStatus = false;
  WhoTakePicking whoTakePicking = WhoTakePicking(ordersId: '', administratorsSku: '', administratorsName: '', dateStart: '', dateUpdate: '');
  //process picking
  var processPickingRepository = di.get<ProcessPickingRespository>();
  // local data
  var productRepository = di.get<ProductRepository>();

  Future<bool> checkTakePicking(String ordersId) async {
    whoOwnsPickingStatus = false;
    WhoTakePicking? response = await processPickingRepository.whoTakePicking(ordersId);
    if (kDebugMode) {
      print("response: ${response!.administratorsSku} - ${PickingVars.USERSKU}");
    }
    if (response != null && response.administratorsSku != "" && response.administratorsSku != PickingVars.USERSKU) {
      // si esta variable es true entonces otra persona hace el picking
      // sacamos el popup para avisar
      whoOwnsPickingStatus = true;
      whoTakePicking = response;
      //print("whoOwnsPickingStatus: $whoOwnsPickingStatus");
      notifyListeners();
    }
    return whoOwnsPickingStatus;
  }

  // el usuario registrado deja el picking para el otro usuario
  void leavePicking(List<OrdersProducts> ordersProductsList) async {
    for (var item in ordersProductsList) {
      // borramos los productos de la base de datos local
      var entityProduct = await productRepository.getProductById(int.parse(item.ordersProductsId));
      if (entityProduct != null) {
        productRepository.deleteProduct(entityProduct);
      }
    }
    notifyListeners();
  }

  // el usuario registrado recupera el picking que le ha sido quitado
  void takePicking(String ordersId) async {
    await processPickingRepository.takePicking(ordersId);
    notifyListeners();
  }

  Future<InserPickingCodeResponse> insertPickingCode(String pickingCode, String ordersId) async {
    return await processPickingRepository.insertPickingCode(pickingCode, ordersId);
  }

  /*Future<OrdersProductsResponse> getOrdersProducts(int idCliente, int ordersId, int cajasId) async {
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
      return OrdersProductsResponse(status: false, body: [], post: "");
    }
    await getVersion();
    // print("$idCliente - $ordersId - $cajasId");
    print("URL: ${PickingVars.URL_API}");
    http.Response response;
    try {
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'action': "products", //
          'idcliente': idCliente.toString(),
          'orders_id': ordersId.toString(),
          'cajas_id': cajasId.toString(),
          'languages_id': PickingVars.languageId
        }),
      );

      log(response.body);
      if (response.statusCode == 200) {
        return await OrdersProductsResponse.fromJson(json.decode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return OrdersProductsResponse(status: false, body: [], post: "");
      }
    } catch (e) {
      return OrdersProductsResponse(status: false, body: [], post: "");
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
  }*/

  Future<List<StockLocations>> findStockLocations(String idcliente, String productsId) async {
    return await processPickingRepository.findStockLocations(idcliente, productsId);
  }
}
