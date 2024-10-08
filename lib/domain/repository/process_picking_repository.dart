import 'dart:isolate';

import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';

abstract class ProcessPickingRespository {
  Future<PickingProcessResponse> startPicking(PickingProcess pickingProcess);
  Future<WhoPickingProcess?> whoOwnsPicking(String ordersId);
  Future<void> endPickingProcess(PickingProcess pickingProcess);
  Future<WhoTakePicking?> whoTakePicking(String ordersId);
  Future<void> takePicking(String ordersId);
  Future<InserPickingCodeResponse> insertPickingCode(String pickingCode, String ordersId);
  Future<List<StockLocations>> findStockLocations(String idcliente, String productsId);
}
