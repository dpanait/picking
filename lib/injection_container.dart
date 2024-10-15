import 'package:floor/floor.dart';
import 'package:get_it/get_it.dart';
import 'package:piking/data/local/database.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/data/local/repository/product_repository_impl.dart';
import 'package:piking/data/local/repository/products_location_local_repository_impl.dart';
import 'package:piking/data/remote/repository/inventory_repository_impl.dart';
import 'package:piking/data/remote/repository/languages_repository_impl.dart';
import 'package:piking/data/remote/repository/products_location_repository_impl.dart' as ProductsLocationRepositoryImplOld;
import 'package:piking/data/remote/repository/location_repository.dart';
import 'package:piking/data/remote/repository/login_repository_impl.dart';
import 'package:piking/data/remote/repository/picking_details_repository_impl.dart';
import 'package:piking/data/remote/repository/process_picking_repository_impl.dart';
import 'package:piking/data/remote/repository/relocate_repository_impl.dart';
import 'package:piking/data/remote/repository/serie_lote_repository_impl.dart';
import 'package:piking/feature/stock/data/remote/repository/search_location_repository_impl.dart';
import 'package:piking/feature/stock/data/remote/repository/stock_entry_repository_impl.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/data/remote/utils/locate_stock_api.dart';
import 'package:piking/domain/repository/inventory_repository.dart';
import 'package:piking/domain/repository/languages_repository.dart';
import 'package:piking/domain/repository/products_location_local_repository.dart';
import 'package:piking/domain/repository/products_location_repository.dart' as ProductsLocationRepositoryOld;
import 'package:piking/domain/repository/location_repository.dart';
import 'package:piking/domain/repository/login_repository.dart';
import 'package:piking/domain/repository/process_picking_repository.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';
import 'package:piking/domain/repository/picking_repository.dart';
import 'package:piking/data/remote/repository/picking_repositoy_impl.dart';
import 'package:piking/domain/repository/relocate_repository.dart';
import 'package:piking/domain/repository/serie_lote_repository.dart';
import 'package:piking/feature/stock/data/remote/utils/location_api.dart';
import 'package:piking/feature/stock/domain/repository/search_location_repository.dart';
import 'package:piking/feature/stock/domain/repository/stock_entry_repository.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:piking/feature/stock/data/remote/repository/products_location_repository_impl.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/data/remote/repository/store_repository_impl.dart';
import 'package:piking/feature/stock/domain/repository/store_repository.dart' as StoreRepositoryStock;
import 'package:piking/feature/stock/data/remote/repository/store_repository_impl.dart' as StoreRepositoryStockImpl;

final di = GetIt.instance;

Future<void> initializeDependencies() async {
  // final migration1to2 = Migration(1, 2, (database) async {
  //   await database.execute(
  //       'ALTER TABLE `Product` ADD COLUMN (`ordersProductsId` TEXT NOT NULL, `ordersId` TEXT NOT NULL, `ordersSku` TEXT NOT NULL, `productsId` TEXT NOT NULL, `productsSku` TEXT NOT NULL, `barcode` TEXT NOT NULL, `referencia` TEXT NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` TEXT NOT NULL, `image` TEXT NOT NULL, `picking` TEXT NOT NULL, `location` TEXT NOT NULL, `locationId` TEXT NOT NULL, `quantityProcessed` TEXT NOT NULL, `serieLote` TEXT NOT NULL, `udsPack` TEXT NOT NULL, `udsBox` TEXT NOT NULL, `pickingCode` TEXT NOT NULL, PRIMARY KEY (`ordersProductsId`))');
  // });
  final migration3to4 = Migration(3, 4, (database) async {
    database.execute('DROP TABLE IF EXISTS ProductsLocationEntity');
    await database.execute('DROP TABLE IF EXISTS Product');
  });
  final migrationCreateTable = Migration(3, 4, (database) async {
    await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`ordersProductsId` TEXT NOT NULL, `ordersId` TEXT NOT NULL, `ordersSku` TEXT NOT NULL, `productsId` TEXT NOT NULL, `productsSku` TEXT NOT NULL, `barcode` TEXT NOT NULL, `referencia` TEXT NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` TEXT NOT NULL, `image` TEXT NOT NULL, `picking` TEXT NOT NULL, `location` TEXT NOT NULL, `locationId` TEXT NOT NULL, `quantityProcessed` TEXT NOT NULL, `serieLote` TEXT NOT NULL, `udsPack` TEXT NOT NULL, `udsBox` TEXT NOT NULL, `pickingCode` TEXT NOT NULL, `stock` TEXT NOT NULL, PRIMARY KEY (`ordersProductsId`))');
    await database.execute(
            'CREATE TABLE IF NOT EXISTS `ProductsLocationEntity` (`locationsProductsId` INTEGER NOT NULL, `produtsId` INTEGER NOT NULL, `productsSku` TEXT NOT NULL, `quantity` INTEGER NOT NULL, `quantityProcessed` INTEGER NOT NULL, `cajasId` INTEGER NOT NULL, `productsName` TEXT NOT NULL, `productsQuantity` INTEGER NOT NULL, `located` INTEGER NOT NULL, `locationsFavorite` INTEGER NOT NULL, `reference` TEXT NOT NULL, `locationsId` INTEGER NOT NULL, `newLocationId` INTEGER NOT NULL, `location` TEXT NOT NULL, `cajasAlias` INTEGER NOT NULL, `cajasName` TEXT NOT NULL, `quantityMax` INTEGER NOT NULL, `image` TEXT NOT NULL, `udsPack` INTEGER NOT NULL, `udsBox` INTEGER NOT NULL, PRIMARY KEY (`locationsProductsId`))');
  });
  final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
    .addMigrations([migration3to4, migrationCreateTable])
    .build(); //addMigrations([migration1to2]).build();

  //print(await $FloorAppDatabase.sowPath());
  di.registerSingleton<AppDatabase>(database);
  di.registerSingleton<Api>(Api());
  di.registerSingleton<LocateStockApi>(LocateStockApi());
  di.registerSingleton<LocationApi>(LocationApi());

  // Dio
  //di.registerSingleton<Dio>(Dio());
  di.registerSingleton<ProductRepository>(ProductRepositoryImpl(di()));
  di.registerSingleton<PickingRepository>(PickingRepositoryImpl(di()));
  di.registerSingleton<StoreRepository>(StoreRepositoryImpl(di()));
  di.registerSingleton<LoginRepository>(LoginRepositoryImpl(di()));
  di.registerSingleton<PickingDetailsRepository>(PickingDetailsRepositoryImpl(di()));
  di.registerSingleton<InventoryRepository>(InventoryRepositoryImpl(di()));
  di.registerSingleton<LocationRepository>(LocationRepositoryImpl(di()));
  di.registerSingleton<StockEntryRepository>(StockEntryRepositoryImpl(di()));
  di.registerSingleton<RelocateRepository>(RelocateRepositoryImpl(di()));
  di.registerSingleton<SerieLoteRepository>(SerieLoteRepositoryImpl(di()));
  di.registerSingleton<LanguagesRepository>(LanguagesRepositoryImpl(di()));
  di.registerSingleton<ProcessPickingRespository>(ProcessPickingRepositoryImpl(di()));
  // loacte stock
  di.registerSingleton<ProductsLocationRepositoryOld.ProductsLocationRepository>(ProductsLocationRepositoryImplOld.ProductsLocationRepositoryImpl(di()));
  di.registerSingleton<ProductsLocationLocalRepository>(ProductsLocationLocalRepositoryImpl(di()));
  //Stock
  di.registerSingleton<ProductsLocationRepository>(ProductsLocationRepositoryImpl(di()));
  // search locations
  di.registerSingleton<SearchLocationRepository>(SearchLocationRepositoryImpl(di()));
  // stores 
  di.registerSingleton<StoreRepositoryStock.StoreRepository>(StoreRepositoryStockImpl.StoreRepositoryImpl(di()));
  //di.registerFactory(() => ProcessPickingRepositoryImpl(di()));
}
