import 'package:piking/domain/entity/products_location_entity.dart';

abstract class ProductsLocationLocalRepository {
  Future<List<ProductsLocationEntity>> findAllProductsLocations();

  Future<ProductsLocationEntity?> findProductLocationById(int locationProductsId);

  Future<void> insertProduct(ProductsLocationEntity productsLocation);

  Future<void> updateQuantityProcessed(int locationsProductsId, int quantityProcessed);

  Future<void> updateLocation(int locationsProductsId, int newLocationId);

  Future<void> deleteProduct(ProductsLocationEntity productsLocation);

  Future<void> deleteTable();
}
