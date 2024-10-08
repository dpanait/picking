import 'package:piking/data/remote/model/serie_lote_response.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/model/objects.dart';
import 'package:piking/domain/repository/serie_lote_repository.dart';
import 'package:piking/domain/transformer/SerieLoteResponseToSerieLotes.dart';

class SerieLoteRepositoryImpl implements SerieLoteRepository {
  final Api _apiInstance;
  SerieLoteRepositoryImpl(this._apiInstance);

  @override
  Future<List<SerieLotes>> getSerieLotes(int ordersId, int idCliente, int cajasId) async {
    SerieLoteResponse response = await _apiInstance.getSerieLote(ordersId, idCliente, cajasId);
    return response.toSerieLotes(); //SerieLoteResponseToSerieLotes.toSerieLotes(response);
  }

  @override
  Future<void> saveSerieLote(int ordersId, SerieLoteList serieLote) async {
    await _apiInstance.saveSerieLote(ordersId, serieLote);
  }
}
