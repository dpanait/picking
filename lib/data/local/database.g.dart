// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ProductDao? _productDaoInstance;

  ProductsLocationDao? _productsLocationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`ordersProductsId` TEXT NOT NULL, `ordersId` TEXT NOT NULL, `ordersSku` TEXT NOT NULL, `productsId` TEXT NOT NULL, `productsSku` TEXT NOT NULL, `barcode` TEXT NOT NULL, `referencia` TEXT NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` TEXT NOT NULL, `image` TEXT NOT NULL, `picking` TEXT NOT NULL, `location` TEXT NOT NULL, `locationId` TEXT NOT NULL, `quantityProcessed` TEXT NOT NULL, `serieLote` TEXT NOT NULL, `udsPack` TEXT NOT NULL, `udsBox` TEXT NOT NULL, `pickingCode` TEXT NOT NULL, `stock` TEXT NOT NULL, PRIMARY KEY (`ordersProductsId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ProductsLocationEntity` (`locationsProductsId` INTEGER NOT NULL, `produtsId` INTEGER NOT NULL, `productsSku` TEXT NOT NULL, `quantity` INTEGER NOT NULL, `quantityProcessed` INTEGER NOT NULL, `cajasId` INTEGER NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` INTEGER NOT NULL, `located` INTEGER NOT NULL, `locationsFavorite` INTEGER NOT NULL, `reference` TEXT NOT NULL, `locationsId` INTEGER NOT NULL, `newLocationId` INTEGER NOT NULL, `location` TEXT NOT NULL, `cajasAlias` INTEGER NOT NULL, `cajasName` TEXT NOT NULL, `quantityMax` INTEGER NOT NULL, `image` TEXT NOT NULL, `udsPack` INTEGER NOT NULL, `udsBox` INTEGER NOT NULL, PRIMARY KEY (`locationsProductsId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  ProductsLocationDao get productsLocationDao {
    return _productsLocationDaoInstance ??=
        _$ProductsLocationDao(database, changeListener);
  }
}

class _$ProductDao extends ProductDao {
  _$ProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _productInsertionAdapter = InsertionAdapter(
            database,
            'Product',
            (Product item) => <String, Object?>{
                  'ordersProductsId': item.ordersProductsId,
                  'ordersId': item.ordersId,
                  'ordersSku': item.ordersSku,
                  'productsId': item.productsId,
                  'productsSku': item.productsSku,
                  'barcode': item.barcode,
                  'referencia': item.referencia,
                  'productsName': item.productsName,
                  'productsQuantity': item.productsQuantity,
                  'image': item.image,
                  'picking': item.picking,
                  'location': item.location,
                  'locationId': item.locationId,
                  'quantityProcessed': item.quantityProcessed,
                  'serieLote': item.serieLote,
                  'udsPack': item.udsPack,
                  'udsBox': item.udsBox,
                  'pickingCode': item.pickingCode,
                  'stock': item.stock
                }),
        _productDeletionAdapter = DeletionAdapter(
            database,
            'Product',
            ['ordersProductsId'],
            (Product item) => <String, Object?>{
                  'ordersProductsId': item.ordersProductsId,
                  'ordersId': item.ordersId,
                  'ordersSku': item.ordersSku,
                  'productsId': item.productsId,
                  'productsSku': item.productsSku,
                  'barcode': item.barcode,
                  'referencia': item.referencia,
                  'productsName': item.productsName,
                  'productsQuantity': item.productsQuantity,
                  'image': item.image,
                  'picking': item.picking,
                  'location': item.location,
                  'locationId': item.locationId,
                  'quantityProcessed': item.quantityProcessed,
                  'serieLote': item.serieLote,
                  'udsPack': item.udsPack,
                  'udsBox': item.udsBox,
                  'pickingCode': item.pickingCode,
                  'stock': item.stock
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Product> _productInsertionAdapter;

  final DeletionAdapter<Product> _productDeletionAdapter;

  @override
  Future<List<Product>> findAllProducts() async {
    return _queryAdapter.queryList('SELECT * FROM Product',
        mapper: (Map<String, Object?> row) => Product(
            row['ordersProductsId'] as String,
            row['ordersId'] as String,
            row['ordersSku'] as String,
            row['productsId'] as String,
            row['productsSku'] as String,
            row['barcode'] as String,
            row['referencia'] as String,
            row['productsName'] as String,
            row['productsQuantity'] as String,
            row['image'] as String,
            row['picking'] as String,
            row['location'] as String,
            row['locationId'] as String,
            row['quantityProcessed'] as String,
            row['serieLote'] as String,
            row['udsPack'] as String,
            row['udsBox'] as String,
            row['pickingCode'] as String,
            row['stock'] as String));
  }

  @override
  Future<Product?> findProductById(int ordersProductsId) async {
    return _queryAdapter.query(
        'SELECT * FROM Product WHERE ordersProductsId = ?1',
        mapper: (Map<String, Object?> row) => Product(
            row['ordersProductsId'] as String,
            row['ordersId'] as String,
            row['ordersSku'] as String,
            row['productsId'] as String,
            row['productsSku'] as String,
            row['barcode'] as String,
            row['referencia'] as String,
            row['productsName'] as String,
            row['productsQuantity'] as String,
            row['image'] as String,
            row['picking'] as String,
            row['location'] as String,
            row['locationId'] as String,
            row['quantityProcessed'] as String,
            row['serieLote'] as String,
            row['udsPack'] as String,
            row['udsBox'] as String,
            row['pickingCode'] as String,
            row['stock'] as String),
        arguments: [ordersProductsId]);
  }

  @override
  Future<List<Product>> findByOrderId(int ordersId) async {
    return _queryAdapter.queryList('SELECT * FROM Product WHERE ordersId = ?1',
        mapper: (Map<String, Object?> row) => Product(
            row['ordersProductsId'] as String,
            row['ordersId'] as String,
            row['ordersSku'] as String,
            row['productsId'] as String,
            row['productsSku'] as String,
            row['barcode'] as String,
            row['referencia'] as String,
            row['productsName'] as String,
            row['productsQuantity'] as String,
            row['image'] as String,
            row['picking'] as String,
            row['location'] as String,
            row['locationId'] as String,
            row['quantityProcessed'] as String,
            row['serieLote'] as String,
            row['udsPack'] as String,
            row['udsBox'] as String,
            row['pickingCode'] as String,
            row['stock'] as String),
        arguments: [ordersId]);
  }

  @override
  Future<bool?> updateQuantityProcessed(
    int ordersProductsId,
    int quantityProcessed,
  ) async {
    return _queryAdapter.query(
        'UPDATE Product SET quantityProcessed = ?2 WHERE ordersProductsId = ?1',
        mapper: (Map<String, Object?> row) => (row.values.first as int) != 0,
        arguments: [ordersProductsId, quantityProcessed]);
  }

  @override
  Future<bool?> updateProductsQuantity(
    int ordersProductsId,
    int productsQuantity,
  ) async {
    return _queryAdapter.query(
        'UPDATE Product SET productsQuantity = ?2 WHERE ordersProductsId = ?1',
        mapper: (Map<String, Object?> row) => (row.values.first as int) != 0,
        arguments: [ordersProductsId, productsQuantity]);
  }

  @override
  Future<void> updatePicking(
    int ordersProductsId,
    int picking,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Product SET picking = ?2 WHERE ordersProductsId = ?1',
        arguments: [ordersProductsId, picking]);
  }

  @override
  Future<void> updatePickingCode(
    int ordersProductsId,
    String pickingCode,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Product SET pickingCode = ?2 WHERE ordersProductsId = ?1',
        arguments: [ordersProductsId, pickingCode]);
  }

  @override
  Future<int?> findOrdersProductsProcesed(int ordersId) async {
    return _queryAdapter.query(
        'SELECT count(ordersProductsId) AS numLineProcesed FROM Product WHERE ordersId = ?1 AND CAST(productsQuantity as integer) = quantityProcessed',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [ordersId]);
  }

  @override
  Future<void> truncateTable() async {
    await _queryAdapter.queryNoReturn(
        'delete from Product; update sqlite_sequence set seq=0 where name=Product;');
  }

  @override
  Future<void> deleteTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Product');
  }

  @override
  Future<void> insertProduct(Product product) async {
    await _productInsertionAdapter.insert(product, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProduct(Product product) async {
    await _productDeletionAdapter.delete(product);
  }
}

class _$ProductsLocationDao extends ProductsLocationDao {
  _$ProductsLocationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _productsLocationEntityInsertionAdapter = InsertionAdapter(
            database,
            'ProductsLocationEntity',
            (ProductsLocationEntity item) => <String, Object?>{
                  'locationsProductsId': item.locationsProductsId,
                  'produtsId': item.produtsId,
                  'productsSku': item.productsSku,
                  'quantity': item.quantity,
                  'quantityProcessed': item.quantityProcessed,
                  'cajasId': item.cajasId,
                  'productsName': item.productsName,
                  'productsQuantity': item.productsQuantity,
                  'located': item.located,
                  'locationsFavorite': item.locationsFavorite,
                  'reference': item.reference,
                  'locationsId': item.locationsId,
                  'newLocationId': item.newLocationId,
                  'location': item.location,
                  'cajasAlias': item.cajasAlias,
                  'cajasName': item.cajasName,
                  'quantityMax': item.quantityMax,
                  'image': item.image,
                  'udsPack': item.udsPack,
                  'udsBox': item.udsBox
                }),
        _productsLocationEntityDeletionAdapter = DeletionAdapter(
            database,
            'ProductsLocationEntity',
            ['locationsProductsId'],
            (ProductsLocationEntity item) => <String, Object?>{
                  'locationsProductsId': item.locationsProductsId,
                  'produtsId': item.produtsId,
                  'productsSku': item.productsSku,
                  'quantity': item.quantity,
                  'quantityProcessed': item.quantityProcessed,
                  'cajasId': item.cajasId,
                  'productsName': item.productsName,
                  'productsQuantity': item.productsQuantity,
                  'located': item.located,
                  'locationsFavorite': item.locationsFavorite,
                  'reference': item.reference,
                  'locationsId': item.locationsId,
                  'newLocationId': item.newLocationId,
                  'location': item.location,
                  'cajasAlias': item.cajasAlias,
                  'cajasName': item.cajasName,
                  'quantityMax': item.quantityMax,
                  'image': item.image,
                  'udsPack': item.udsPack,
                  'udsBox': item.udsBox
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProductsLocationEntity>
      _productsLocationEntityInsertionAdapter;

  final DeletionAdapter<ProductsLocationEntity>
      _productsLocationEntityDeletionAdapter;

  @override
  Future<List<ProductsLocationEntity>> findAllProductsLocations() async {
    return _queryAdapter.queryList('SELECT * FROM ProductsLocationEntity',
        mapper: (Map<String, Object?> row) => ProductsLocationEntity(
            locationsProductsId: row['locationsProductsId'] as int,
            produtsId: row['produtsId'] as int,
            productsSku: row['productsSku'] as String,
            quantity: row['quantity'] as int,
            quantityProcessed: row['quantityProcessed'] as int,
            cajasId: row['cajasId'] as int,
            productsName: row['productsName'] as String,
            productsQuantity: row['productsQuantity'] as int,
            located: row['located'] as int,
            locationsFavorite: row['locationsFavorite'] as int,
            reference: row['reference'] as String,
            locationsId: row['locationsId'] as int,
            newLocationId: row['newLocationId'] as int,
            location: row['location'] as String,
            cajasAlias: row['cajasAlias'] as int,
            cajasName: row['cajasName'] as String,
            quantityMax: row['quantityMax'] as int,
            image: row['image'] as String,
            udsPack: row['udsPack'] as int,
            udsBox: row['udsBox'] as int));
  }

  @override
  Future<ProductsLocationEntity?> findProductLocationById(
      int locationsProductsId) async {
    return _queryAdapter.query(
        'SELECT * FROM ProductsLocationEntity WHERE locationsProductsId = ?1',
        mapper: (Map<String, Object?> row) => ProductsLocationEntity(
            locationsProductsId: row['locationsProductsId'] as int,
            produtsId: row['produtsId'] as int,
            productsSku: row['productsSku'] as String,
            quantity: row['quantity'] as int,
            quantityProcessed: row['quantityProcessed'] as int,
            cajasId: row['cajasId'] as int,
            productsName: row['productsName'] as String,
            productsQuantity: row['productsQuantity'] as int,
            located: row['located'] as int,
            locationsFavorite: row['locationsFavorite'] as int,
            reference: row['reference'] as String,
            locationsId: row['locationsId'] as int,
            newLocationId: row['newLocationId'] as int,
            location: row['location'] as String,
            cajasAlias: row['cajasAlias'] as int,
            cajasName: row['cajasName'] as String,
            quantityMax: row['quantityMax'] as int,
            image: row['image'] as String,
            udsPack: row['udsPack'] as int,
            udsBox: row['udsBox'] as int),
        arguments: [locationsProductsId]);
  }

  @override
  Future<void> updateQuantityProcessed(
    int locationsProductsId,
    int quantityProcessed,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ProductsLocationEntity SET quantityProcessed = ?2 WHERE locationsProductsId = ?1',
        arguments: [locationsProductsId, quantityProcessed]);
  }

  @override
  Future<void> updateLocation(
    int locationsProductsId,
    int newLocationId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ProductsLocationEntity SET newLocationId = ?2 WHERE locationsProductsId = ?1',
        arguments: [locationsProductsId, newLocationId]);
  }

  @override
  Future<void> deleteTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ProductsLocationEntity');
  }

  @override
  Future<void> insertProduct(ProductsLocationEntity productsLocation) async {
    await _productsLocationEntityInsertionAdapter.insert(
        productsLocation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProduct(ProductsLocationEntity productsLocation) async {
    await _productsLocationEntityDeletionAdapter.delete(productsLocation);
  }
}
