import 'package:piking/feature/stock/data/remote/model/store_model.dart';
import 'package:piking/feature/stock/data/remote/response/store_response.dart';
import 'package:piking/feature/stock/data/remote/utils/location_api.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/repository/store_repository.dart';

class StoreRepositoryImpl extends StoreRepository{

  final LocationApi _apiInstance;
  StoreRepositoryImpl(this._apiInstance);

  @override
  Future<List<StoreEntity>> getStore() async {
    StoreResponse storeResponse = await _apiInstance.getAllStore();
    
    if(storeResponse.status){
      List<StoreEntity> storeEntity = [];
      storeResponse.body.forEach((element) {
        storeEntity.add(element);
      });
      
      return storeEntity;
    } else {
      return [];
    }
  }
  
}