import 'package:piking/data/local/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllPorducts();

  Future<Product?> getProductById(int ordersProductsId);

  Future<void> deleteProduct(Product product);

  Future<List<Product>> getByOrdersId(int orderId);

  Future<void> insertProduct(Product product);

  Future<bool> updateQuantityProcessed(int ordersProductsId, int quantityProcessed);

  Future<bool> updateProductsQuantity(int ordersProductsId, int productsQuantity);

  Future<void> updatePicking(int ordersProductsId, int picking);

  Future<void> updatePickingCode(int ordersProductsId, String pickingCode);

  Future<int?> findOrdersProductsProcesed(int ordersId);

  Future<String> truncateTable();

  Future<void> deleteTable();
}
