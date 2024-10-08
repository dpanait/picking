import 'package:piking/data/local/dao/product_dao.dart';




class Database {
  late ProductDao dao;
  /* _connect() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('product_database.db').build();
    dao = database.productDao;
    return dao;
  }*/

  //@override
  initState() {
    // _connect();
  }
}
