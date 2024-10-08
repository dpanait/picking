import 'package:piking/data/local/database.dart';
import 'package:piking/domain/entity/products_location_entity.dart';
import 'package:piking/domain/repository/products_location_local_repository.dart';

class ProductsLocationLocalRepositoryImpl implements ProductsLocationLocalRepository {
  final AppDatabase _appDatabase;
  ProductsLocationLocalRepositoryImpl(this._appDatabase);
  @override
  Future<void> deleteProduct(ProductsLocationEntity productsLocation) {
    return _appDatabase.productsLocationDao.deleteProduct(productsLocation);
  }

  @override
  Future<void> deleteTable() {
    return _appDatabase.productsLocationDao.deleteTable();
  }

  @override
  Future<List<ProductsLocationEntity>> findAllProductsLocations() {
    return _appDatabase.productsLocationDao.findAllProductsLocations();
  }

  @override
  Future<ProductsLocationEntity?> findProductLocationById(int locationsProductsId) {
    return _appDatabase.productsLocationDao.findProductLocationById(locationsProductsId);
  }

  @override
  Future<void> insertProduct(ProductsLocationEntity productsLocation) {
    return _appDatabase.productsLocationDao.insertProduct(productsLocation);
  }

  @override
  Future<void> updateLocation(int locationsProductsId, int newLocationId) {
    throw _appDatabase.productsLocationDao.updateLocation(locationsProductsId, newLocationId);
  }

  @override
  Future<void> updateQuantityProcessed(int locationsProductsId, int quantityProcessed) {
    throw _appDatabase.productsLocationDao.updateQuantityProcessed(locationsProductsId, quantityProcessed);
  }
}
