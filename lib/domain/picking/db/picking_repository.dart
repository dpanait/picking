import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:piking/domain/picking/db/data_base_picking_connexion.dart';
import 'package:piking/domain/picking/model/product_model.dart';
//import 'package:piking/domain/picking/model/product_model.dart';
import 'package:sqflite/sqflite.dart';

class PickingRepository {
  late PickingDatabaseConnection _pickingDatabaseConnection;

  PickingRepository() {
    _pickingDatabaseConnection = PickingDatabaseConnection();
  }

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _pickingDatabaseConnection.setDatabase();
      return _database;
    }
  }

  //Read All Record
  readData(table) async {
    var connection = await database;
    return await connection?.query(table);
  }

  //Insert User
  insertData(table, data) async {
    var connection = await database;
    return await connection?.insert(table, data);
  }

  //Read a Single Record By ID
  readDataById(table, itemId) async {
    var connection = await database;
    return await connection?.query(table, where: 'id=?', whereArgs: [itemId]);
  }

  //Update User
  updateProduct(table, data) async {
    var connection = await database;
    if (kDebugMode) {
      print("Data: ${jsonEncode(data)}");
    }
    try {
      return await connection?.update(table, data,
          where: 'ordersProductsId=?',
          whereArgs: [data['ordersProductsId']],
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      if (kDebugMode) {
        print("Error Update: $e");
      }
      return [];
    }
  }

  //Delete User
  deleteDataById(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where id=$itemId");
  }

  //delete table
  deleteTableProduct(table) async {
    var connection = await database;
    return await connection?.delete(table);
  }

  findByOrdersProductsId(String table, int ordersProductsId) async {
    var connetion = await database;
    //return connetion?.query(table, where: 'ordersProductsId=?', whereArgs: [ordersProductsId]);
    List<Map<String, Object?>>? result = await connetion?.query(table,
        columns: ['ordersProductsId'],
        where: 'ordersProductsId = ?',
        whereArgs: [ordersProductsId]);

    List<ProductS> products =
        result!.map((map) => ProductS.mapToProduct(map)).toList();
    return products;
  }

  findByOrdersId(String table, int ordersId) async {
    var connetion = await database;
    //return connetion?.query(table, where: 'ordersId=?', whereArgs: [ordersId]);
    List<Map<String, Object?>>? result = await connetion
        ?.query(table, where: 'ordersId=?', whereArgs: [ordersId]);
    List<ProductS> products =
        result!.map((map) => ProductS.mapToProduct(map)).toList();

    return products;
  }

  /*Product mapToProduct(Map<String, Object?> row) {
    return Product(
        ordersId: (row['ordersId'] as int).toString(),
        ordersSku: row['ordersSku'] as String,
        ordersProductsId: (row['ordersProductsId'] as int).toString(),
        productsId: row['productsId'] as int,
        productsSku: row['productsSku'] as String,
        barcode: row['barcode'] as String,
        referencia: row['referencia'] as String?,
        productsName: row['productsName'] as String,
        productsQuantity: (row['productsQuantity'] as int).toString(),
        image: row['image'] as String?,
        picking: (row['piking'] as int).toString(),
        location: row['location'] as String,
        quantityProcessed: row['quantityProcessed'] as int,
        serieLote: row['serieLote'] as String);
  }*/
}
