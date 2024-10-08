import 'package:piking/domain/response/location_response.dart';

abstract class LocationRepository {
  Future<LocationResponse> checkMultiLocations(String productsEan);
}
