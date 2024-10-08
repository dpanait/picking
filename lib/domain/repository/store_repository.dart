import 'package:piking/data/remote/model/store_response.dart';

abstract class StoreRepository {
  Future<StoreResponse> getAllStore(int idCliente);
}
