import 'dart:async';
import 'package:floor/floor.dart';
import 'package:piking/data/local/dao/products_location_dao.dart';
import 'package:piking/data/local/entity/product_entity.dart';
import 'package:piking/domain/entity/products_location_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/product_dao.dart';

part 'database.g.dart';

@Database(version: 4, entities: [Product, ProductsLocationEntity])
abstract class AppDatabase extends FloorDatabase {
  ProductDao get productDao;
  ProductsLocationDao get productsLocationDao;

  static databaseBuilder(String s) {}
}


  // final migration1to2 = Migration(1, 2, (database) async {
  //   await database.execute(
  //       'ALTER TABLE `Product` ADD COLUMN (`ordersProductsId` TEXT NOT NULL, `ordersId` TEXT NOT NULL, `ordersSku` TEXT NOT NULL, `productsId` TEXT NOT NULL, `productsSku` TEXT NOT NULL, `barcode` TEXT NOT NULL, `referencia` TEXT NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` TEXT NOT NULL, `image` TEXT NOT NULL, `picking` TEXT NOT NULL, `location` TEXT NOT NULL, `locationId` TEXT NOT NULL, `quantityProcessed` TEXT NOT NULL, `serieLote` TEXT NOT NULL, `udsPack` TEXT NOT NULL, `udsBox` TEXT NOT NULL, `pickingCode` TEXT NOT NULL, PRIMARY KEY (`ordersProductsId`))');
  // });