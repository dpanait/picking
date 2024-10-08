import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:piking/data/dto/inventoryDto.dart';
import 'package:piking/feature/stock/data/remote/model/stock_entry_reponse.dart';
import 'package:piking/data/remote/model/inventory_response.dart';
import 'package:piking/data/remote/model/relocate_response.dart';
import 'package:piking/data/remote/model/serie_lote_response.dart';
import 'package:piking/domain/response/inventory_response.dart';
import 'package:piking/data/remote/model/login_response.dart';
import 'package:piking/data/remote/model/multi_location_response.dart';
import 'package:piking/data/remote/model/orders_products_response.dart';
import 'package:piking/data/remote/model/picking_response.dart';
import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/response/languages_reponse.dart';
import 'package:piking/domain/response/location_response.dart';
import 'package:piking/domain/model/objects.dart';
import 'package:piking/domain/model/orders.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';
import 'package:piking/domain/model/relocate.dart';
import 'package:piking/domain/response/relocate_response.dart';
import 'package:piking/feature/stock/domain/model/stock_entry.dart';
import 'package:piking/vars.dart';

class Api {
  Future<OrdersProductsResponse> getOrdersProductsBack(int idCliente, int ordersId, int cajasId) async {
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
    Dio dio = Dio();

    // URL de la API a la que quieres hacer la solicitud POST
    String url = PickingVars.URL_API;

    // Datos que deseas enviar en la solicitud POST
    Map<String, String> datos = {
      'action': "products", //
      'idcliente': idCliente.toString(),
      'orders_id': ordersId.toString(),
      'cajas_id': cajasId.toString(),
      'languages_id': PickingVars.languageId
    };
    try {
      // Realizar la solicitud POST
      Response response = await dio.post(
        url,
        data: jsonEncode(datos), // Los datos que quieres enviar
        options: Options(headers: {'Content-Type': 'application/json;  charset=UTF-8'}),
      );
      //log(jsonEncode(datos));
      // Verificar el código de estado de la respuesta
      if (response.statusCode == 200) {
        // La solicitud fue exitosa
        log('Respuesta: ${response.data}');
        return OrdersProductsResponse.fromJson(json.decode(response.data));
      } else {
        // La solicitud falló con un código de estado diferente de 200
        log('Error: ${response.statusCode}');
        return OrdersProductsResponse(status: false, body: [], post: "");
      }
    } catch (error) {
      // Capturar y manejar cualquier error que ocurra durante la solicitud
      print('Error exception: $error');
      return OrdersProductsResponse(status: false, body: [], post: "");
    }
  }

  // picking details
  // buscamos un orders_products
  Future<OrdersProductsResponse> getOrdersProducts(int idCliente, int ordersId, int cajasId) async {
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
        try {
          return OrdersProductsResponse.fromJson(json.decode(response.body));
        } catch (e, stackTrace) {
          log("Error exception http: $e");
          log("Error: $stackTrace");
          return OrdersProductsResponse(status: false, body: [], post: "");
        }
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return OrdersProductsResponse(status: false, body: [], post: "");
      }
    } catch (e) {
      log("Error exception http: $e");
      return OrdersProductsResponse(status: false, body: [], post: "");
    }
  }

  // guardamos el picking
  Future<void> savePicking(List<OrdersProducts> ordersProducts, String pickingCode) async {
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
    }
    await getVersion();
    print("Url savePicking: ${PickingVars.URL_API}");
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "save_piking", //
          'IDCLIENTE': PickingVars.IDCLIENTE.toString(),
          'orders_id': ordersProducts[0].ordersId,
          'user_sku': PickingVars.USERSKU,
          'picking_code': pickingCode,
          'body': ordersProducts
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE save picking: ${jsonEncode(response.body)}");
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SavePicking catch: $e");
      }
    }
  }

  Future<StockLocationsResponse> findStockLocations(String idcliente, String productsId) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected == false) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
    }
    await getVersion();
    try {
      print("URL: ${PickingVars.URL_API}");
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "find_stock_locations", //
          'idcliente': idcliente,
          'products_id': productsId
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          log("RESPONSE find stock locations: ${response.body}");
        }
        return StockLocationsResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
        return StockLocationsResponse(status: false, stockLoctatiosList: []);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error stock locations: $e");
      }
      return StockLocationsResponse(status: false, stockLoctatiosList: []);
    }
  }

  // proces picking
  Future<PickingProcessResponse> startPicking(PickingProcess pickingProcess) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected == false) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
    }
    String versionNumber = await getVersion();
    // String version = "pre/dani";
    // if (PickingVars.ENVIRONMENT == "pro") {
    //   version = "pro/buy${versionNumber}";
    // }
    try {
      print("URL: ${PickingVars.URL_API}");
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "start_piking", //
          'idcliente': PickingVars.IDCLIENTE,
          'orders_id': pickingProcess.ordersId,
          'administrators_sku': pickingProcess.administratorsSku,
          'readed_products': pickingProcess.readedProducts,
          'readed_locations': pickingProcess.readedLocations,
          'date_start': pickingProcess.dateEnd,
          'date_end': pickingProcess.dateStart,
          'picking_code': pickingProcess.pickingCode,
          'app_version': PickingVars.appVersion
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE start picking: ${jsonEncode(response.body)}");
        }
        return PickingProcessResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
        return PickingProcessResponse(status: false);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      return PickingProcessResponse(status: false);
    }
  }

  Future<PickingProcessResponseWoh> whoOwnsPicking(String ordersId) async {
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
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "who_owns_piking", //
          'idcliente': PickingVars.IDCLIENTE,
          'orders_id': ordersId,
          'app_version': PickingVars.appVersion
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE who owns picking: ${jsonEncode(response.body)}");
        }
        return PickingProcessResponseWoh.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
        return PickingProcessResponseWoh(status: false, whoPickingProcess: null);
      }
    } catch (e) {
      if (kDebugMode) {
        print("whoOwnsPicking catch: $e");
      }
      return PickingProcessResponseWoh(status: false, whoPickingProcess: null);
    }
  }

  Future<WhoTakePickingResponse> whoTakePicking(String ordersId) async {
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
    }
    await getVersion();
    WhoTakePicking whoTakePickingEmpty = WhoTakePicking(ordersId: "", administratorsSku: "", administratorsName: "", dateStart: "", dateUpdate: '');
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "who_take_picking", //
          'idcliente': PickingVars.IDCLIENTE,
          'orders_id': ordersId,
          'app_version': PickingVars.appVersion
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE who take picking: ${jsonEncode(response.body)}");
        }
        return WhoTakePickingResponse.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
        return WhoTakePickingResponse(status: false, whoTakePicking: whoTakePickingEmpty);
      }
    } catch (e) {
      if (kDebugMode) {
        print("whoTakePicking catch: $e");
      }
      return WhoTakePickingResponse(status: false, whoTakePicking: whoTakePickingEmpty);
    }
  }

  Future<void> takePicking(String ordersId) async {
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
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "take_picking", //
          'idcliente': PickingVars.IDCLIENTE,
          'orders_id': ordersId,
          'administrators_sku': PickingVars.USERSKU,
          'administrators_name': PickingVars.USERNAME
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE take picking: ${jsonEncode(response.body)}");
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("TakePicking catch: $e");
      }
    }
  }

  Future<void> endPickingProcess(PickingProcess pickingProcess) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected == false) {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "end_piking_process", //
          'idcliente': PickingVars.IDCLIENTE,
          'orders_id': pickingProcess.ordersId,
          'administrators_sku': pickingProcess.administratorsSku,
          'readed_products': pickingProcess.readedProducts,
          'readed_locations': pickingProcess.readedLocations,
          'date_start': pickingProcess.dateEnd,
          'date_end': pickingProcess.dateStart,
          'picking_code': pickingProcess.pickingCode,
          'app_version': PickingVars.appVersion
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print("RESPONSE who owns picking: ${jsonEncode(response.body)}");
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<InserPickingCodeResponse> insertPickingCode(String pickingCode, String ordersId) async {
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
    }
    await getVersion();
    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'action': "insert_picking_code",
        'idcliente': PickingVars.IDCLIENTE.toString(),
        'user_sku': PickingVars.USERSKU,
        'orders_id': ordersId,
        'picking_code': pickingCode,
        'app_version': PickingVars.appVersion
      }),
    );
    if (response.statusCode == 200) {
      // todo ha ido bien
      if (kDebugMode) {
        print(jsonEncode(response.body));
      }
      return InserPickingCodeResponse.fromJson(jsonDecode(response.body));
    } else {
      if (kDebugMode) {
        print("Error: ${jsonDecode(response.body)}");
      }
      return InserPickingCodeResponse(status: false, message: "");
    }
  }

  // guradamosla nota
  Future<void> saveNote(String note, String ordersId) async {
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
    }
    await getVersion();
    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'action': "add_picking_note",
        'IDCLIENTE': PickingVars.IDCLIENTE.toString(),
        'user_sku': PickingVars.USERSKU,
        'orders_id': ordersId,
        'note': note
      }),
    );
    if (response.statusCode == 200) {
      // todo ha ido bien
      if (kDebugMode) {
        print(jsonEncode(response.body));
      }
    } else {
      if (kDebugMode) {
        print("Error: ${jsonDecode(response.body)}");
      }
    }
  }

  Future<void> saveNoteNonePickingCode(String ordersId) async {
    print("ordersId: $ordersId - ${PickingVars.USERSKU} - ${PickingVars.IDCLIENTE.toString()}");
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
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "add_note_picking_code_none",
          'IDCLIENTE': PickingVars.IDCLIENTE.toString(),
          'user_sku': PickingVars.USERSKU,
          'orders_id': ordersId,
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print(jsonEncode(response.body));
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<void> saveWhoOverridePicking(PickingProcess pickingProcess, String whoAdministratorsSku, String whoAdministratorsName) async {
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
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "add_who_override_picking",
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'orders_id': pickingProcess.ordersId,
          'actual_user': pickingProcess.toJson(),
          'who_administrators_sku': whoAdministratorsSku,
          'who_administrators_name': whoAdministratorsName,
          'app_version': PickingVars.appVersion
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print(jsonEncode(response.body));
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  // picking list
  // buscamos todos los picking
  Future<List<Orders>?> getAllPickings(int idcliente, int cajasId) async {
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
      return [];
    }
    await getVersion();
    http.Response response;
    print("Url get_picking: ${PickingVars.URL_API}");
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'action': "get_picking", 'idcliente': idcliente.toString(), 'cajas_id': cajasId.toString()}),
    );

    if (kDebugMode) {
      print("getAllPickings: ${response.body}");
    }
    if (response.statusCode == 200) {
      try {
        var responseJson = PickingResponse.fromJson(json.decode(response.body));
        return responseJson.body;
      } catch (e, stackTrace) {
        log("Error exception http: $e");
        log("Error: $stackTrace");
        return [];
      }
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return [];
    }
  }

  Future<Orders> findPickingByOrdersSku(String idcliente, String ordersSku) async {
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
      return Orders.empty();
    }

    await getVersion();
    try {
      http.Response response;
      print("Url get_one_picking: ${PickingVars.URL_API}");
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'action': "get_one_picking", 'idcliente': idcliente, 'orders_sku': ordersSku}),
      );

      if (kDebugMode) {
        print("getAllPickings: ${response.body}");
      }
      if (response.statusCode == 200) {
        var responseJson = PickingResponseUnic.fromJson(json.decode(response.body));
        return responseJson.order;
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return Orders.empty();
      }
    } catch (e) {
      return Orders.empty();
    }
  }

  // guardar nota picking incompleto
  Future<void> savePickingIncomplete(String ordersId, String note) async {
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
      return;
    }
    await getVersion();
    try {
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'action': "add_note_picking_incomplete",
          'idcliente': PickingVars.IDCLIENTE.toString(),
          'user_sku': PickingVars.USERSKU,
          'user_name': PickingVars.USERNAME,
          'orders_id': ordersId,
          'note': note
        }),
      );
      if (response.statusCode == 200) {
        // todo ha ido bien
        if (kDebugMode) {
          print(jsonEncode(response.body));
        }
      } else {
        if (kDebugMode) {
          print("Error: ${jsonDecode(response.body)}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  // inventario
  // buscamos el inventario
  Future<InventoryResponse> saveInventory(int idcliente, InventoryDto inventory) async {
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
      return InventoryResponse(status: false, message: "");
    }
    await getVersion();
    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "save_inventory", //
        'IDCLIENTE': idcliente.toString(),
        'user_sku': PickingVars.USERSKU,
        'body': jsonEncode(inventory)
      }),
    );

    if (response.statusCode == 200) {
      var responseJson = InventoryRemoteResponse.fromJson(json.decode(response.body));
      return InventoryResponse(status: bool.parse(responseJson.status.toString()), message: responseJson.body.toString());
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return InventoryResponse(status: false, message: "");
    }
  }

  // locations
  // mulri locations
  Future<LocationResponse> checkMultiLocations(String productsEan) async {
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
      return LocationResponse(status: false, inventory: []);
    }
    await getVersion();
    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "check_multi_location",
        'IDCLIENTE': PickingVars.IDCLIENTE.toString(),
        'user_sku': PickingVars.USERSKU,
        'cajasId': PickingVars.CAJASID.toString(),
        'productsEan': productsEan.toString()
      }),
    );
    if (response.statusCode == 200) {
      var multiLocationsJson = MultiLocationResponse.fromJson(json.decode(response.body));
      return LocationResponse(status: multiLocationsJson.status, inventory: multiLocationsJson.products);
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return LocationResponse(status: false, inventory: []);
    }
  }

  // stock
  Future<List<StockEntry>> getStockEntryList(int idCliente, int cajasId) async {
    if (kDebugMode) {
      print("Idcliente $idCliente, ${idCliente.toString()} - ${PickingVars.URL_API}");
    }
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
      return [];
    }
    await getVersion();

    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'action': "get_stock_entry", 'idcliente': idCliente.toString(), 'cajas_id': cajasId.toString()}),
    );

    // print(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      var responseJson = StockEntryResponse.fromJson(json.decode(response.body));
      return responseJson.body!;
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return [];
    }
  }

  // mover inventario
  Future<RelocateResponse> saveRelocate(int idcliente, Relocate relocate) async {
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
      return RelocateResponse(status: false, message: "");
    }
    await getVersion();
    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': "save_move_products",
        'IDCLIENTE': idcliente.toString(),
        'user_sku': PickingVars.USERSKU,
        'cajas_id': PickingVars.CAJASID.toString(),
        'body': jsonEncode(relocate)
      }),
    );

    //print(response.body);
    if (response.statusCode == 200) {
      var responseJson = RelocateResponseRemote.fromJson(json.decode(response.body));
      return RelocateResponse(status: responseJson.status, message: responseJson.body.toString());
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return RelocateResponse(status: false, message: "");
    }
  }

  //serieLote
  Future<SerieLoteResponse> getSerieLote(int ordersId, int idCliente, int cajasId) async {
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
      return SerieLoteResponse(status: "", serieLotes: []);
    }
    await getVersion();

    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'action': "get_serie_lote", 'orders_id': ordersId.toString(), 'IDCLIENTE': idCliente.toString(), 'cajas_id': cajasId.toString()}),
    );

    print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      var responseJson = SerieLoteResponse.fromJson(json.decode(response.body));
      return responseJson;
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      return SerieLoteResponse(status: "", serieLotes: []);
    }
  }

  Future<void> saveSerieLote(int ordersId, SerieLoteList serieLotes) async {
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
    }
    await getVersion();

    http.Response response;
    response = await http.post(
      Uri.parse(PickingVars.URL_API),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'action': "save_serie_lote", 'orders_id': ordersId.toString(), 'serie_lotes': serieLotes.toJson()}),
    );

    print(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      var responseJson = SerieLoteResponse.fromJson(json.decode(response.body));
      //return responseJson;
    } else {
      if (kDebugMode) {
        print("Request failed");
      }
      //return SerieLoteResponse(ordersProductsId: "", serieLoteItem: []);
    }
  }

  // store
  // buscamos los almacenes del cliente
  Future<StoreResponse> getAllStore(int idCliente) async {
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
      return StoreResponse(status: false);
    }
    await getVersion();
    if (kDebugMode) {
      print("Idcliente $idCliente}");
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
        body: jsonEncode(<String, String>{'action': "almacen", 'idcliente': idCliente.toString()}),
      );
      if (response.statusCode == 200) {
        return StoreResponse.fromJson(json.decode(response.body));
      } else {
        if (kDebugMode) {
          print("Request failed");
        }
        return StoreResponse(status: false);
      }
    } catch (e) {
      print("Error: $e");
      return StoreResponse(status: false);
    }
  }

  //login
  Future<LoginResponse> login(String code1, String code2, String code3) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      await getVersion();
      http.Response response;
      response = await http.post(
        Uri.parse(PickingVars.URL_API),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'action': "login",
          'code1': code1, //"22G3",
          'code2': code2,
          'code3': code3
        }),
      );
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        //print(response.body);
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        return LoginResponse(status: false, companyName: "", userName: "");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Error: No tienes connexion a internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10, //
          backgroundColor: const Color.fromARGB(255, 184, 183, 183),
          textColor: const Color.fromARGB(255, 250, 2, 2),
          fontSize: 16.0);
      return LoginResponse(status: false, companyName: "", userName: "");
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

  Future<LanguagesResponse> getLanguages() async {
    http.Response response;
    bool isConnected = await checkInternetConnection();
    try {
      if (isConnected) {
        response = await http.post(Uri.parse(PickingVars.URL_API),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'action': "get_languages",
            }));
        print(response.body);
        if (response.statusCode == 200) {
          LanguagesResponse languagesResponse = LanguagesResponse.fromJson(jsonDecode(response.body));
          return languagesResponse;
        } else {
          return LanguagesResponse(status: false, languages: []);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: No tienes connexion a internet",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 10, //
            backgroundColor: const Color.fromARGB(255, 184, 183, 183),
            textColor: const Color.fromARGB(255, 250, 2, 2),
            fontSize: 16.0);
        return LanguagesResponse(status: false, languages: []);
      }
    } catch (e) {
      return LanguagesResponse(status: false, languages: []);
    }
  }

  Future<bool> checkInternetConnection() async {
    bool isConected = await InternetConnectionChecker().hasConnection;
    return isConected;
  }
}
