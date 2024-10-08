import 'package:equatable/equatable.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';


class LocationResponseEntity extends Equatable{
  late LocationOriginEntity locationOrigin = LocationOriginEntity.empty();
  late LocationZeroEntity locationZero = LocationZeroEntity.empty();

  LocationResponseEntity({required this.locationOrigin, required this.locationZero});

  static empty(){
    return LocationResponseEntity(
        locationOrigin: LocationOriginEntity.empty(),
        locationZero: LocationZeroEntity.empty()
    );
  }
  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      locationOrigin,
      locationZero
    ];
  }
}
// ignore: must_be_immutable
class LocationOriginEntity extends Equatable{

  List<ProductsLocationEntity>? productsLocations = [];
  List<Location>? locations = [];

  LocationOriginEntity({
    required this.productsLocations,
    required this.locations
  });

  static empty() {
    return LocationOriginEntity(
        productsLocations: const [],
        locations: const []
    );
  }
  
  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      productsLocations,
      locations
    ];
  }
}

class LocationZeroEntity extends Equatable{

  List<ProductsLocationEntity> locationZero = [];

  LocationZeroEntity({required this.locationZero});

  static empty(){
    return LocationZeroEntity(locationZero: const []);

  }

  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      locationZero
    ];
  }

}