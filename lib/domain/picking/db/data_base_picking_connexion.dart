import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PickingDatabaseConnection {
  Future<Database> setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_picking.db');
    if (kDebugMode) {
      print("Path: $path");
    }
    var database =
        await openDatabase(path, version: 1, onCreate: _createDatabase);
    return database;
  }

  Future<void> _createDatabase(Database database, int version) async {
    String sql = """CREATE TABLE products (
          ordersProductsId INTEGER PRIMARY KEY,
          ordersId INTEGER,
          ordersSku TEXT,
          productsId INTEGER,
          productsSku TEXT,
          barcode TEXT,
          referencia TEXT,
          productsName TEXT,
          productsQuantity INTEGER,
          image TEXT,
          piking INTEGER,
          location TEXT,
          quantityProcessed INTEGER,
          serieLote TEXT
        );""";
    await database.execute(sql);
  }

}
