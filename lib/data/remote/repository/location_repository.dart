import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/response/location_response.dart';
import 'package:piking/domain/repository/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  late final Api _apiInstance;

  LocationRepositoryImpl(this._apiInstance);
  @override
  Future<LocationResponse> checkMultiLocations(String productsEan) async {
    return await _apiInstance.checkMultiLocations(productsEan);
  }
}
