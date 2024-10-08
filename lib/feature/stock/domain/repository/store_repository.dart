import 'package:piking/feature/stock/domain/entities/store_entity.dart';

abstract class StoreRepository{
  Future<List<StoreEntity>> getStore();
}