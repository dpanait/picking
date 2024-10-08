import 'package:piking/feature/stock/domain/entities/store_entity.dart';

// ignore: must_be_immutable
class Store extends StoreEntity{
  Store({
    super.cajasId,
    super.cajasName,
    super.cajasNameY
  });
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      cajasId: int.parse(json['cajas_id']),
      cajasName: json['cajas_name'],
      cajasNameY: json["cajas_name_Y"]
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["cajas_id"] = cajasId;
    data["cajas_name"] = cajasName;
    data["cajas_name_Y"] = cajasNameY;
    return data;
  }
  factory Store.fromEntity(StoreEntity storeEntity){
    return Store(
      cajasId: storeEntity.cajasId,
      cajasName: storeEntity.cajasName,
      cajasNameY: storeEntity.cajasNameY
    );
  }
  static fromStore(Store store){
    return StoreEntity(
      cajasId: store.cajasId,
      cajasName: store.cajasName,
      cajasNameY: store.cajasNameY
    );
  }

}