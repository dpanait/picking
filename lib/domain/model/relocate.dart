class Relocate {
  String? location;
  int? ean;
  int? productsQuantity;
  int? newLocation;

  Relocate({this.location, this.ean, this.productsQuantity, this.newLocation});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['productsEan'] = ean;
    data['quantityProducts'] = productsQuantity;
    data['newLocation'] = newLocation;
    return data;
  }
}
