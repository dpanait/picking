import 'dart:developer';

import 'package:piking/domain/model/picking_process.dart';

class PickingProcessResponse {
  late bool status;
  late WhoPickingProcess whoOwnsPicking;

  PickingProcessResponse({required this.status});
  PickingProcessResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    var whoOwnsPickingJson = json['who_owns_picking'];
    if (whoOwnsPickingJson is Map<String, dynamic>) {
      whoOwnsPicking = WhoPickingProcess.fromJson(whoOwnsPickingJson);
    } else {
      whoOwnsPicking = WhoPickingProcess(ordersId: "", administratorsName: "", administratorsSku: "", dateStart: "");
    }
  }
}

class PickingProcessResponseWoh {
  late bool status;
  late WhoPickingProcess? whoPickingProcess;
  PickingProcessResponseWoh({required this.status, required this.whoPickingProcess});

  PickingProcessResponseWoh.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    whoPickingProcess = WhoPickingProcess.fromJson(json['who_picking_process']);
  }
}

class WhoTakePickingResponse {
  late bool status;
  late WhoTakePicking whoTakePicking;
  WhoTakePickingResponse({required this.status, required this.whoTakePicking});

  WhoTakePickingResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    var whoTakePickingJosn = json['who_take_picking'];

    if (whoTakePickingJosn is Map<String, dynamic>) {
      whoTakePicking = WhoTakePicking.fromJson(whoTakePickingJosn);
    } else {
      whoTakePicking = WhoTakePicking(ordersId: "", administratorsSku: "", administratorsName: "", dateStart: "", dateUpdate: '');
    }
  }
}

class InserPickingCodeResponse {
  late bool status;
  late String message;
  InserPickingCodeResponse({required this.status, required this.message});

  InserPickingCodeResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }
}

class StockLocationsResponse {
  late bool status;
  late List<StockLocations> stockLoctatiosList = [];
  StockLocationsResponse({required this.status, required this.stockLoctatiosList});
  StockLocationsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    (json['stock_locations'] as List).forEach((element) {
      stockLoctatiosList.add(StockLocations.fromJson(element));
    });
  }
}
