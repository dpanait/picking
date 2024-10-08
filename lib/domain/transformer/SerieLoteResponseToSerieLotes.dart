import 'package:piking/data/remote/model/serie_lote_response.dart';
import 'package:piking/domain/model/objects.dart';

class SerieLoteResponseToSerieLotes {
  SerieLoteResponseToSerieLotes._();

  static List<SerieLotes> toSerieLotes(SerieLoteResponse serieLotesResponse) {
    List<SerieLotes> serieLotesList = [];
    for (var element in serieLotesResponse.serieLotes) {
      serieLotesList.add(SerieLotes(
          ordersProductsId: element.ordersProductsId, //
          serieLoteItem: element.serieLoteItem));
    }

    return serieLotesList;
  }
}
