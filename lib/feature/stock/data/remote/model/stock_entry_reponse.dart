import 'package:piking/feature/stock/domain/model/stock_entry.dart';

class StockEntryResponse {
  List<StockEntry>? body;

  StockEntryResponse({this.body});

  StockEntryResponse.fromJson(Map<String, dynamic> json) {
    if (json['body'] != null) {
      body = <StockEntry>[];
      json['body'].forEach((v) {
        body!.add(StockEntry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
