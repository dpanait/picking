import "package:piking/domain/model/objects.dart";

abstract class SerieLoteRepository {
  Future<List<SerieLotes>> getSerieLotes(int ordersId, int idCliente, int cajasId);
  Future<void> saveSerieLote(int ordersId, SerieLoteList serieLote);
}
