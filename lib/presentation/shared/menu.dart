import 'package:flutter/material.dart';
import 'package:piking/presentation/home_page.dart';
import 'package:piking/presentation/inventory_page.dart';
//import 'package:piking/pages/picking_list_page.dart';
import 'package:piking/presentation/picking_list_page.dart';
import 'package:piking/presentation/relocate_page.dart';
import 'package:piking/presentation/stock_entry_list_page.dart';
//import 'package:piking/presentation/stock_entry_page.dart';
import 'package:piking/feature/stock/presentation/stock_move_page.dart';
import 'package:piking/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MenuDrawer extends StatefulWidget {
  late int idcliente = 0;
  //late BodyPicking orders = BodyPicking();
  //late int cajasId = 0;

  MenuDrawer({super.key, required this.idcliente /*, required this.orders, required this.cajasId*/});

  @override
  State<MenuDrawer> createState() => _MenuState();
}

class _MenuState extends State<MenuDrawer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var companyName = "";
  setComanyName() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      companyName = PickingVars.ENVIRONMENT == "pro" ? prefs.getString("companyName") ?? "Aplicación en modo desarollo" : "Aplicación en modo desarollo";
    });
  }

  @override
  void initState() {
    super.initState();
    setComanyName();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
          color: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                  child: SizedBox(
                width: double.infinity,
                child: Center(child: Text(companyName, style: const TextStyle(fontSize: 20, color: Colors.black54))),
              )),
              ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/house.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Home",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(idcliente: widget.idcliente),
                      ),
                    );
                  }),
              ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/picking.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Picking",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickingListPage(idcliente: widget.idcliente),
                      ),
                    );
                  }),
              ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/inventory.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Inventario",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryPage(idcliente: widget.idcliente),
                      ),
                    );
                  }),
              /*ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/add_stock.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Entrada",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockEntryListPage(idcliente: widget.idcliente),
                      ),
                    );
                  }),
              ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/relocate.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Reubicar",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RelocatePage(idcliente: widget.idcliente),
                      ),
                    );
                  }),*/
              ListTile(
                  leading: Transform.scale(
                    scale: 1,
                    child: IconButton(
                      icon: Image.asset('assets/icons/relocate.png'),
                      onPressed: null,
                    ),
                  ),
                  title: const Text(
                    "Ubicar",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockMovePage(idcliente: widget.idcliente),
                      ),
                    );
                  })
            ],
          )),
    );
  }
}
