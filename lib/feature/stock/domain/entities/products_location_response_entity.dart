import 'package:equatable/equatable.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/data/remote/model/products_multi_ean_model.dart';

class ProductsLocationResponseEntity extends Equatable{
  late String type;
  late LocationResponseEntity locationResponse = LocationResponseEntity.empty();
  late List<ProductsMultiEan> productsMultiEan = [];

  ProductsLocationResponseEntity({
    required this.type,
    required this.locationResponse,
    required this.productsMultiEan
  });

  static empty(){
    return ProductsLocationResponseEntity(
        type : "",
        locationResponse: LocationResponseEntity.empty(),
        productsMultiEan: const []
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      type,
      locationResponse,
      productsMultiEan
    ];
  }

}