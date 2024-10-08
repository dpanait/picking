import 'package:floor/floor.dart';
import 'package:piking/domain/entity/products_location_entity.dart';

@dao
abstract class ProductsLocationDao {
  @Query('SELECT * FROM ProductsLocationEntity')
  Future<List<ProductsLocationEntity>> findAllProductsLocations();

  @Query('SELECT * FROM ProductsLocationEntity WHERE locationsProductsId = :locationsProductsId')
  Future<ProductsLocationEntity?> findProductLocationById(int locationsProductsId);

  @insert
  Future<void> insertProduct(ProductsLocationEntity productsLocation);

  @Query("UPDATE ProductsLocationEntity SET quantityProcessed = :quantityProcessed WHERE locationsProductsId = :locationsProductsId")
  Future<void> updateQuantityProcessed(int locationsProductsId, int quantityProcessed);

  @Query("UPDATE ProductsLocationEntity SET newLocationId = :newLocationId WHERE locationsProductsId = :locationsProductsId")
  Future<void> updateLocation(int locationsProductsId, int newLocationId);

  @delete
  Future<void> deleteProduct(ProductsLocationEntity productsLocation);

  @Query('DELETE FROM ProductsLocationEntity')
  Future<void> deleteTable();
}
