import 'package:equatable/equatable.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';

// ignore: must_be_immutable
class ProductsMultiEanEntity extends Equatable{
  late int productsId;
  late String productsSku;
  late String eanRef;
  late String productsName;
  late String image;
  late LocationResponseEntity? details;
  ProductsMultiEanEntity({
    required this.productsId,
    required this.productsSku,
    required this.eanRef,
    required this.productsName,
    required this.image,
    this.details
  });
  static empty() {
    return ProductsMultiEanEntity(
      productsId: 0, //
      productsSku: "",
      eanRef: "",
      productsName: "",
      image: '',
      details: LocationResponseEntity.empty()
    );
  }
  
  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      productsId, //
      productsSku,
      eanRef,
      productsName,
      image,
      details
    ];
  }
}