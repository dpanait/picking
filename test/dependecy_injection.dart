import 'package:get_it/get_it.dart';
import 'package:piking/data/local/database.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/data/local/repository/product_repository_impl.dart';
import 'package:piking/data/remote/repository/inventory_repository_impl.dart';
import 'package:piking/data/remote/repository/location_repository.dart';
import 'package:piking/data/remote/repository/login_repository_impl.dart';
import 'package:piking/data/remote/repository/picking_details_repository_impl.dart';
import 'package:piking/data/remote/repository/relocate_repository_impl.dart';
import 'package:piking/feature/stock/data/remote/repository/stock_entry_repository_impl.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/repository/inventory_repository.dart';
import 'package:piking/domain/repository/location_repository.dart';
import 'package:piking/domain/repository/login_repository.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';
import 'package:piking/domain/repository/picking_repository.dart';
import 'package:piking/data/remote/repository/picking_repositoy_impl.dart';
import 'package:piking/domain/repository/relocate_repository.dart';
import 'package:piking/feature/stock/domain/repository/stock_entry_repository.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/data/remote/repository/store_repository_impl.dart';

final di = GetIt.instance;

Future<void> initializeDependencies() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  //print(await $FloorAppDatabase.sowPath());
  di.registerSingleton<AppDatabase>(database);
  di.registerSingleton<Api>(Api());

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
}
