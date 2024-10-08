import 'dart:isolate';

import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';
import 'package:piking/domain/repository/process_picking_repository.dart';

class ProcessPickingRepositoryImpl implements ProcessPickingRespository {
  final Api _apiInstance;

  ProcessPickingRepositoryImpl(this._apiInstance);

  @override
  Future<PickingProcessResponse> startPicking(PickingProcess pickingProcess) async {
    return _apiInstance.startPicking(pickingProcess);
  }

  @override
  Future<WhoPickingProcess?> whoOwnsPicking(String ordersId) async {
    PickingProcessResponseWoh responseWhoOwnsPicking = await _apiInstance.whoOwnsPicking(ordersId);
    return responseWhoOwnsPicking.whoPickingProcess;
  }

  @override
  Future<void> endPickingProcess(PickingProcess pickingProcess) {
    return _apiInstance.endPickingProcess(pickingProcess);
  }

  @override
  Future<WhoTakePicking?> whoTakePicking(String ordersId) async {
    WhoTakePickingResponse responseWhoOwnsPicking = await _apiInstance.whoTakePicking(ordersId);
    return responseWhoOwnsPicking.whoTakePicking;
  }

  @override
  Future<void> takePicking(String ordersId) async {
    _apiInstance.takePicking(ordersId);
  }

  @override
  Future<InserPickingCodeResponse> insertPickingCode(String pickingCode, String ordersId) async {
    return _apiInstance.insertPickingCode(pickingCode, ordersId);
  }

  @override
  Future<List<StockLocations>> findStockLocations(String idcliente, String productsId) async {
    StockLocationsResponse stockLocationsResponse = await _apiInstance.findStockLocations(idcliente, productsId);
    return stockLocationsResponse.stockLoctatiosList;
  }
}
