import 'package:piking/domain/picking/db/picking_repository.dart';
import 'package:piking/domain/picking/model/product_model.dart';

class PickingService {
  late PickingRepository _repository;

  PickingService() {
    _repository = PickingRepository();
  }

  //Save Picking
  saveProduct(ProductS product) async {
    return await _repository.insertData('products', product.productMap());
  }

  //Read All Users
  readAllProducts() async {
    return await _repository.readData('products');
  }

  //find by ordersProductsId
  findByOrdersProductsId(int ordersProductsId) async {
    return await _repository.findByOrdersProductsId(
        'products', ordersProductsId);
  }

  // find byOrdersid
  findByOrdersId(int ordersId) async {
    return await _repository.findByOrdersId('products', ordersId);
  }

  //Edit User
  updateProduct(ProductS product) async {
    return await _repository.updateProduct('products', product.productMap());
  }

  deleteProduct(productId) async {
    return await _repository.deleteDataById('products', productId);
  }

  deleteTableProducts() async {
    return await _repository.deleteTableProduct('products');
  }
}
