import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/orders_products.dart';

class TestProvider extends ChangeNotifier {
  int _counter = 0;
  late List<OrdersProducts> ordersProductsList = [];

  // Getter para obtener el valor actual del contador
  int get counter => _counter;

  // Método para incrementar el contador
  void increment() {
    _counter++;
    // Notifica a los oyentes (widgets) que el valor ha cambiado
    notifyListeners();
  }

  void adOrdersProducts(OrdersProducts ordersProducts) {
    ordersProductsList.add(ordersProducts);
  }

  void printOrders() {
    if (kDebugMode) {
      print(ordersProductsList[0]);
    }
  }

  // Método para restablecer el contador
  void reset() {
    _counter = 0;
    notifyListeners();
  }
}
