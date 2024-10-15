import 'package:floor/floor.dart';
import 'package:piking/data/local/entity/product_entity.dart';

@dao
abstract class ProductDao {
  @Query('SELECT * FROM Product')
  Future<List<Product>> findAllProducts();

  @Query('SELECT * FROM Product WHERE ordersProductsId = :ordersProductsId')
  Future<Product?> findProductById(int ordersProductsId);

  @Query('SELECT * FROM Product WHERE ordersId = :ordersId')
  Future<List<Product>> findByOrderId(int ordersId);

  @insert
  Future<void> insertProduct(Product product);

  @Query("UPDATE Product SET quantityProcessed = :quantityProcessed WHERE ordersProductsId = :ordersProductsId")
  Future<bool?> updateQuantityProcessed(int ordersProductsId, int quantityProcessed);

  @Query("UPDATE Product SET productsQuantity = :productsQuantity WHERE ordersProductsId = :ordersProductsId")
  Future<bool?> updateProductsQuantity(int ordersProductsId, int productsQuantity);


  @Query("UPDATE Product SET picking = :picking WHERE ordersProductsId = :ordersProductsId")
  Future<void> updatePicking(int ordersProductsId, int picking);

  @Query("UPDATE Product SET pickingCode = :pickingCode WHERE ordersProductsId = :ordersProductsId")
  Future<void> updatePickingCode(int ordersProductsId, String pickingCode);

  @delete
  Future<void> deleteProduct(Product product);

  @Query("SELECT count(ordersProductsId) AS numLineProcesed FROM Product WHERE ordersId = :ordersId AND CAST(productsQuantity as integer) = quantityProcessed")
  Future<int?> findOrdersProductsProcesed(int ordersId);

  @Query("delete from Product; update sqlite_sequence set seq=0 where name=Product;")
  Future<void> truncateTable();

  @Query('DELETE FROM Product')
  Future<void> deleteTable();
}
