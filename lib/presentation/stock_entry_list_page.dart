import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/feature/stock/domain/model/stock_entry.dart';
import 'package:piking/feature/stock/domain/repository/stock_entry_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/presentation/shared/menu.dart';
import 'package:piking/presentation/stock_entry_page.dart';
import 'package:piking/vars.dart';

class StockEntryListPage extends StatefulWidget {
  final int idcliente;
  const StockEntryListPage({super.key, required this.idcliente});

  @override
  State<StockEntryListPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<StockEntryListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<StockEntry> stockEntry = [];
  List<StockEntry> stockEntryFounded = [];
  int? selectedOrderIndex; // Índice del pedido seleccionado
  late String snackBar = "Tiene que elejir un almacen";
  late TextEditingController _searchController = TextEditingController();
  late int cajasId = 0;
  var stockEntryRepository = di.get<StockEntryRepository>();

  _postOrders() async {
    if (PickingVars.CAJASID > 0) {
      List<StockEntry> stockEntryResponse = await stockEntryRepository.getStockEntryList(PickingVars.IDCLIENTE, PickingVars.CAJASID);

      if (kDebugMode) {
        print("Response orders: $stockEntryResponse");
      }

      if (stockEntryResponse.isEmpty) {
        snackBar = 'No se ha encontrado pickings en este almacen';
      }

      for (var item in stockEntryResponse) {
        if (kDebugMode) {
          print("Stock entry: ${item.ordersSku}");
        }
      }

      setState(() {
        stockEntry = stockEntryResponse;
        stockEntryFounded = stockEntry;
      });
    } else {
      snackBar = 'Porfavor elige un almacen en el menu de arriba';
    }
  }

  @override
  initState() {
    super.initState();
    _postOrders();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    //_db.product.deleteAll();
    //_db.close();
    //productRepository.truncateTable();
    super.dispose();
  }

  void _runFilter(String search) {
    List<StockEntry> results = [];
    if (search.isEmpty) {
      results = stockEntry;
    } else {
      results = stockEntry
          .where((order) => order.city != null && order.city!.toUpperCase().contains(search.toUpperCase()) || order.ordersSku!.contains(search))
          .toList();
    }
    setState(() {
      stockEntryFounded = results;
    });
  }

  void loadOrdersProducts() {
    if (kDebugMode) {
      print("Load ordersProducts");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: MenuDrawer(idcliente: widget.idcliente),
      appBar:
          CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: widget.idcliente, title: "Entrada", onActionPressed: _postOrders),
      body: Center(
          child: stockEntryFounded.isEmpty
              ? Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      snackBar,
                      style: const TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold),
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _runFilter(value),
                        decoration: InputDecoration(
                            labelText: "Buscar",
                            prefixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    stockEntryFounded = stockEntry;
                                  });
                                },
                                icon: const Icon(Icons.clear))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.separated(
                      itemCount: stockEntryFounded.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final order = stockEntryFounded[index];
                        final isSelected = selectedOrderIndex == index;
                        return InkWell(
                          onTap: () {
                            if (PickingVars.CAJASID == 0) {
                              const snackBar = SnackBar(
                                content: Text('Porfavor elige un almacen en el menu de los tres puntos'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              return;
                            }
                            // Acción cuando se hace clic en el elemento de la lista
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockEntryPage(
                                  idcliente: widget.idcliente,
                                  orders: order,
                                  cajasId: cajasId,
                                  callback: loadOrdersProducts,
                                ),
                              ),
                            );
                          },
                          onTapDown: (_) {
                            setState(() {
                              selectedOrderIndex = index;
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              selectedOrderIndex = null;
                            });
                          },
                          child: Container(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            child: ListTile(
                              title: Text('Pedido ${order.ordersSku} \nFecha: ${order.datePurchased}'),
                              subtitle: Text(
                                'Ciudad: ${order.city ?? ""}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ))
                  ]))),
    );
  }
}
