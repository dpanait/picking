import 'package:piking/domain/model/objects.dart';

class SerieLoteResponse {
  final String status;
  final List<SerieLotes> serieLotes;

  SerieLoteResponse({required this.status, required this.serieLotes});

  factory SerieLoteResponse.fromJson(Map<String, dynamic> json) {
    return SerieLoteResponse(
        status: json['status'], //
        serieLotes: json['serie_lotes']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['serie_lotes'] = serieLotes;
    return data;
  }

  toSerieLotes() {
    List<SerieLotes> serieLotesList = [];
    for (var element in serieLotes) {
      serieLotesList.add(SerieLotes(
          ordersProductsId: element.ordersProductsId, //
          serieLoteItem: element.serieLoteItem));
    }

    return serieLotesList;
  }
}
