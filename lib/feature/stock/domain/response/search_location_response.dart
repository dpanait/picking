import 'package:piking/feature/stock/data/remote/model/location_model.dart';

class SearchLocationResponse{
  late bool status;
  late List<Location> resultSearch = [];
  SearchLocationResponse({
    required this.status,
    required this.resultSearch
  });

  SearchLocationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['locations'] != null) {
      json['locations'].forEach((item) {
        resultSearch.add(Location.fromJson(item));
      });
    } else {
    }
  }
  static empty(){
    return SearchLocationResponse(status: false, resultSearch: []);
  }
}