import 'package:flutter/foundation.dart';
import 'package:piking/data/local/database.dart';
import 'package:piking/data/local/entity/product_entity.dart';
import 'package:piking/data/local/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _appDatabase;
  ProductRepositoryImpl(this._appDatabase);

  @override
  Future<void> deleteProduct(Product product) async {
    // implement deleteProduct
    _appDatabase.productDao.deleteProduct(product);
  }

  @override
  Future<List<Product>> getAllPorducts() async {
    // implement getAllPorducts
    return _appDatabase.productDao.findAllProducts();
  }

  @override
  Future<List<Product>> getByOrdersId(int ordersId) async {
    // implement getByOrdersId
    return _appDatabase.productDao.findByOrderId(ordersId);
  }

  @override
  Future<Product?> getProductById(int ordersProductsId) async {
    // implement getProductById
    Product? product = await _appDatabase.productDao.findProductById(ordersProductsId);
    if (kDebugMode) {
      print("Product repo: ${product?.ordersProductsId} -- $ordersProductsId");
    }
    if (product?.ordersProductsId == null) {}
    return product;
  }

  @override
  Future<void> insertProduct(Product product) async {
    // implement insertProduct
    _appDatabase.productDao.insertProduct(product);
  }

  @override
  Future<String> truncateTable() async {
    // implement truncateTable
    try {
      await _appDatabase.productDao.truncateTable();
      return "Registros de la tabla de Productos eliminados con exito.";
    } catch (e) {
      return "No se ha elimindo los registros de la tabla Products, motivo: $e";
    }

    //print("Resulut: $result");
  }

  @override
  Future<void> deleteTable() async {
    // implement deleteTable
    _appDatabase.productDao.deleteTable();
  }

  @override
  Future<bool> updateQuantityProcessed(int ordersProductsId, int quantityProcessed) async {
    // implement updateQuentityProcessed
    return _appDatabase.productDao.updateQuantityProcessed(ordersProductsId, quantityProcessed);
  }

  @override
  Future<bool> updateProductsQuantity(int ordersProductsId, int productsQuantity) async {
    // implement updateQuentityProcessed
    return _appDatabase.productDao.updateProductsQuantity(ordersProductsId, productsQuantity);
  }


  @override
  Future<void> updatePicking(int ordersProductsId, int picking) async {
    // implement updatePicking
    _appDatabase.productDao.updatePicking(ordersProductsId, picking);
  }

  @override
  Future<void> updatePickingCode(int ordersProductsId, String pickingCode) async {
    // TODO: implement updatePickingCode
    await _appDatabase.productDao.updatePickingCode(ordersProductsId, pickingCode);
  }

  @override
  Future<int?> findOrdersProductsProcesed(int ordersId) async {
    return await _appDatabase.productDao.findOrdersProductsProcesed(ordersId);
  }
}
