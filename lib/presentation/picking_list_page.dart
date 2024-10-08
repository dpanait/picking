import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/model/orders.dart';
import 'package:piking/domain/repository/picking_repository.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/picking_page.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/presentation/shared/menu.dart';
import 'package:piking/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class PickingListPage extends StatefulWidget {
  const PickingListPage({super.key, required this.idcliente}); // : super(key: key);
  final int idcliente;

  @override
  State<PickingListPage> createState() => _PickingListState();

  @protected
  void didUpdateWidget(PickingListPage oldWidget) {
    _PickingListState();
  }
}

class _PickingListState extends State<PickingListPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences prefs;
  //late PickingResponse response = PickingResponse(status: false);

  //OrdersModel ordersListModel = OrdersModel();
  //StoreModel storeModel = StoreModel();
  StoreResponse storeResponse = StoreResponse(status: false);
  var pickingRepository = di.get<PickingRepository>();
  var storeRepository = di.get<StoreRepository>();

  List<Store> store = [];
  List<Orders> orders = [];
  List<Orders> ordersFounded = [];
  List<OrdersProcesed> ordersProcesed = [];
  int? selectedOrderIndex; // Índice del pedido seleccionado
  late TextEditingController _searchController = TextEditingController();
  late int cajasId = 0;
  late String snackBar = "Tiene que elejir un almacen";
  late String storeLabel = "Almacen";
  var ordersProductsProcesed = 0;
  int currentFilterItem = 0;
  bool isLoaded = true;

  List<PopupMenuItem> storeItem = [];
  // local data
  var productRepository = di.get<ProductRepository>();

  getAllPicking() async {
    prefs = await _prefs;
    PickingVars.IDCLIENTE = prefs.getInt("IDCLIENTE")!;
    //if (PickingVars.CAJASID > 0) {
    try {
      List<Orders> response = (await pickingRepository.getAllPickings(widget.idcliente, PickingVars.CAJASID))!;

      //Body.fromJson(response.body);
      if (response.isEmpty) {
        snackBar = 'No se ha encontrado pickings en este almacen';
      }
      if (mounted) {
        setState(() {
          // cada vez que buscamos pikings vaciamos las listas
          orders = [];
          ordersFounded = [];
          orders = response;
          // despues de vaciar lista asignamos los pickings
          ordersFounded = response;
          isLoaded = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
    /*} else {
      snackBar = 'Porfavor elige un almacen en el menu de arriba';
    }*/
    ordersProcesed = [];
    for (var item in ordersFounded) {
      int? numLineProcessed = await getOrdersProductsProcessed(int.parse(item.ordersId.toString()));
      if (mounted) {
        setState(() {
          ordersProcesed.add(OrdersProcesed(ordersId: int.parse(item.ordersId.toString()), numLineProcessed: int.parse(numLineProcessed.toString())));
        });
      }
      //print("OrdersProcessed: ${item.ordersId} - $numLineProcessed");
    }
  }

  getAllStore() async {
    storeResponse = await storeRepository.getAllStore(PickingVars.IDCLIENTE);
    if (mounted) {
      setState(() {
        storeResponse.body?.forEach((element) {
          store.add(Store.fromJson(element.toJson()));
        });
      });
    }
  }

  Future<int?> getOrdersProductsProcessed(int ordersId) async {
    int? numLIneProcessed = await productRepository.findOrdersProductsProcesed(ordersId);
    return numLIneProcessed;
  }

  @override
  initState() {
    super.initState();
    getAllPicking();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    ordersProcesed = [];
  }

  // cuando volvemos de la lista de pickings
  // una ez hecho el picking recargamos el listado de orders para ver los que quedadn para hacer
  void loadPickingList() {
    if (kDebugMode) {
      print("CallFromDetails");
    }
    getAllPicking();
  }

  void onLeadingPressed() {
    if (kDebugMode) {
      print("Llamada desde la funcion");
    }
    getAllPicking();
    Navigator.of(context).pop();
  }

  void _runFilter(String search) async {
    //print("_runFilter: $search");
    isLoaded = true;
    List<Orders> results = [];
    if (search.isEmpty) {
      results = orders;
    } else {
      if (search.startsWith("222")) {
        results = orders.where((order) => order.pickingCode != null && order.pickingCode.toString() != "" && order.pickingCode!.contains(search)).toList();
        Orders resultsOrder = await pickingRepository.findPickingByOrdersSku(PickingVars.IDCLIENTE.toString(), search);
        if (resultsOrder.ordersId != "") {
          results.add(resultsOrder);
        }
      } else {
        results = orders
            .where((order) =>
                (order.city != null && order.city!.toUpperCase().contains(search.toUpperCase())) ||
                (order.ordersSku! != "" && order.ordersSku!.contains(search.toUpperCase())))
            .toList();
        if (results.isEmpty) {
          Orders resultsOrder = await pickingRepository.findPickingByOrdersSku(PickingVars.IDCLIENTE.toString(), search);
          if (resultsOrder.ordersId != "") {
            results.add(resultsOrder);
          }
        }
      }
    }
    setState(() {
      ordersFounded = results;
      isLoaded = false;
    });
  }

  void _runFilterMenu(int search) {
    isLoaded = true;
    List<Orders> results = [];
    if (search == 0) {
      results = orders;
    }
    if (search > 0 && search == 1) {
      results = orders.where((order) => order.dateStart == null).toList();
    }
    if (search > 0 && search == 2) {
      results = orders.where((order) => order.dateStart != null && order.dateStart != "" && order.dateEnd == "").toList();
    }
    if (search > 0 && search == 3) {
      results = orders.where((order) => order.dateStart != null && order.dateEnd != null && order.dateStart != "" && order.dateEnd != "").toList();
    }

    setState(() {
      ordersFounded = results;
      isLoaded = false;
    });
  }

  @override
  void didUpdateWidget(PickingListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Lógica de actualización aquí
    if (kDebugMode) {
      print("Pagina actualizada");
    }
  }

  @override
  Widget build(BuildContext context) {
    storeItem = [];
    for (var i = 0; i < store.length; i++) {
      storeItem.add(PopupMenuItem<int>(
        value: int.parse(store[i].cajasId!),
        child: Text(
          "${store[i].cajasId} - ${store[i].cajasName ?? store[i].cajasNameY}",
          style: TextStyle(fontWeight: (PickingVars.CAJASID == int.parse(store[i].cajasId!)) ? FontWeight.w700 : FontWeight.normal),
        ),
      ));
    }

    return Scaffold(
      drawer: MenuDrawer(idcliente: widget.idcliente),
      appBar: CustomAppBar(
          icon: null,
          trailingIcon: const Icon(Icons.refresh),
          onPressIconButton: () {},
          idcliente: widget.idcliente,
          title: "Listado de pickings",
          onActionPressed: getAllPicking),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    //onChanged: (value) => _runFilter(value),
                    onSubmitted: (String value) {
                      _runFilter(value);
                    },
                    decoration: InputDecoration(
                        labelText: "Buscar",
                        prefixIcon: IconButton(
                            onPressed: () {
                              _runFilter(_searchController.text);
                            },
                            icon: const Icon(Icons.search)),
                        suffixIcon: IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                ordersFounded = orders;
                              });
                            },
                            icon: const Icon(Icons.clear))),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: PopupMenuButton(
                      // add icon, by default "3 dot" icon
                      // icon: Icon(Icons.book)
                      tooltip: "Filtrar",
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Text(
                              "TODOS",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              "PICKING SIN HACER",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text(
                              "PICKING EMPEZADO",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          const PopupMenuItem<int>(
                            value: 3,
                            child: Text(
                              "PICKING COMPLETO",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          )
                        ];
                      },
                      onSelected: (value) => _runFilterMenu(value)),
                )
              ],
            ),
            //Center(
            //hild:
            isLoaded
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 20, 73, 187),
                      ),
                    ),
                  )

                //const CircularProgressIndicator()
                : Expanded(
                    child: ListView.separated(
                      itemCount: ordersFounded.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final order = ordersFounded[index];
                        final isSelected = selectedOrderIndex == index;
                        String pickingDateStart = order.dateStart != null ? order.dateStart.toString() : "";
                        String pickingDateEnd = order.dateEnd != null ? order.dateEnd.toString() : "";
                        String pickingAdministratorsSku = order.administratorsSku != null ? order.administratorsSku.toString() : "";
                        String administratorsSku = PickingVars.USERSKU != "" ? PickingVars.USERSKU : prefs.getString("code1").toString();
                        
                        if (ordersProcesed.isNotEmpty) {
                        
                          var ordersProcessedObj = ordersProcesed.firstWhere((obj) => obj.ordersId == int.parse(order.ordersId.toString()),
                              orElse: () => OrdersProcesed(ordersId: int.parse(order.ordersId.toString()), numLineProcessed: 0));
                          ordersProductsProcesed = ordersProcessedObj.numLineProcessed;
                        }
                        String colorItem = "FFFFF";
                        if (order.statusColor != null) {
                          colorItem = order.statusColor.toString().substring(1).toUpperCase();
                        }
                        //print("colorItem: $colorItem");

                        String unidades = "";
                        if (order.totalUd > 0) {
                          unidades += " ${order.totalUd} ud";
                        }
                        if (order.totalPack > 0) {
                          unidades += " ${order.totalPack} pack";
                        }
                        if (order.totalBox > 0) {
                          unidades += " ${order.totalBox} caja";
                        }
                        String weight = "";
                        //print("PESO: ${order.weight}");
                        // ignore: unrelated_type_equality_checks
                        if (order.weight!.isNotEmpty && double.parse(order.weight.toString()) > 0) {
                          weight = "${double.parse(order.weight.toString())} kg";
                        }
                        String timeInDay = "";
                        if (order.dateStart != null) {
                          String diferenceTxt = _calculateDifferenceDate(order);

                          timeInDay = " ($diferenceTxt)";
                        }
                        String userPickingText = "";
                        if (order.userPicking != "") {
                          userPickingText = "<bold>${order.userPicking ?? ''} $timeInDay </bold>";
                        }
                        
                        return InkWell(
                          onTap: () async {
                            // if (PickingVars.CAJASID == 0) {
                            //   const snackBar = SnackBar(
                            //     content: Text('Porfavor elige un almacen en el menu de los tres puntos'),
                            //   );
                            //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            //   return;
                            // }
                            if (orders[index].internalNotes.isNotEmpty) {
                              log("Tiene nota: ${orders[index].ordersSku}");

                              String contentNote = "";
                              orders[index].internalNotes.forEach((element) {
                                contentNote +=  "${element.adminName} - ${element.note}\n";

                              });
                               var resultShowDialog = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  
                                  return PopScope(
                                    canPop: false,
                                    onPopInvoked: (didPop) {
                                      //log("onPopInvoked: $didPop");
                                    },
                                    child: AlertDialog(
                                      //backgroundColor: Colors.red[100],
                                      title: const Text(
                                        'Notas internas Almacen',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      content: Text(
                                        contentNote,//"${orders[index].internalNotes[0].note}",
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle: Theme.of(context).textTheme.bodyLarge,
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Ir al picking'),
                                          onPressed: () async {
                                            Navigator.pop(context, true);
                                            return;
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              //log("result_showDialog: $resultShowDialog");

                            } //else {
                              
                              // Acción cuando se hace clic en el elemento de la lista
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickingPage(
                                    idcliente: widget.idcliente,
                                    orders: order,
                                    cajasId: PickingVars.CAJASID,
                                    callback: loadPickingList,
                                  ),
                                ),
                              );
                              //print("navigation result: $result");
                              if (result != null) {
                                if (result is int) {
                                  //print("Orders_id: $result");
                                  var orderIndex = ordersFounded.indexWhere((obj) => int.parse(obj.ordersId.toString()) == result);
                                  if (orderIndex != -1) {
                                    setState(() {
                                      ordersFounded.removeAt(index);
                                    });
                                  }
                                }
                                loadPickingList();
                              }
                            //}
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
                            color: Color(0xFFFFFFF),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Tooltip(
                                          message: "${order.ordersId}",
                                          child: StyledText(
                                              text:
                                                  "<name>Estado:</name> <boldColor>${order.statusText ?? ""}</boldColor> \n<name>Pedido:</name> <bold>${order.ordersSku}</bold>\n<name>Fecha:</name> <bold>${order.datePurchased}</bold>\n<name>Peso:</name> <bold>$weight</bold>\n<name>Num lin:</name> <bold>$ordersProductsProcesed/${order.numLine}</bold>",
                                              tags: {
                                                'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                                'name': StyledTextTag(style: const TextStyle(fontSize: 16)),
                                                'boldColor': StyledTextTag(
                                                    style: TextStyle(fontWeight: FontWeight.bold, backgroundColor: Color(int.parse("0xFF$colorItem"))))
                                              })),
                                      /*(order.picking == "1") || */ (pickingAdministratorsSku != "" && pickingAdministratorsSku != administratorsSku)
                                          ? Container(
                                              alignment: Alignment.topRight,
                                              child: const Icon(
                                                Icons.stop_rounded,
                                                color: Color.fromARGB(255, 255, 1, 1),
                                                size: 50.0,
                                              ))
                                          : pickingDateStart != "" && pickingDateEnd == ""
                                              ? Container(
                                                  alignment: Alignment.topRight,
                                                  child: const Icon(Icons.stop_rounded, color: Color.fromARGB(255, 255, 166, 1), size: 50.0))
                                              : pickingDateStart != "" && pickingDateEnd != ""
                                                  ? Container(
                                                      alignment: Alignment.topRight,
                                                      child: const Icon(Icons.stop_rounded, color: Color.fromARGB(255, 1, 255, 43), size: 50.0))
                                                  : Container(),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: StyledText(
                                          text: "<name>Picking cod:</name> <bold>${order.pickingCode ?? ""}</bold>",
                                          tags: {
                                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                            'name': StyledTextTag(style: const TextStyle(fontSize: 16))
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: StyledText(
                                          text: "<name>Unidades: </name><bold>$unidades</bold>",
                                          tags: {
                                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                            'name': StyledTextTag(style: const TextStyle(fontSize: 16))
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: StyledText(text: '<name>Ciudad:</name> <bold>${order.city ?? ""}</bold>', tags: {
                                          'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                          'name': StyledTextTag(style: const TextStyle(fontSize: 16)),
                                        }),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: StyledText(text: userPickingText, tags: {
                                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                            'name': StyledTextTag(style: const TextStyle(fontSize: 16))
                                          }),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              subtitle:
                                  null, /*Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: StyledText(text: userPickingText, tags: {
                                      'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                      'name': StyledTextTag(style: const TextStyle(fontSize: 16))
                                    }),
                                  ),
                                ],
                              ),*/
                            ),
                          ),
                        );
                      },
                    ),
                  )
            //),
          ],
        ),
      ),
    );
  }

  String _calculateDifferenceDate(Orders order) {
    DateTime fechaInicio = DateTime.parse(order.dateStart.toString());

    // Fecha actual
    DateTime fechaActual = DateTime.now();
    // Calcula la diferencia de tiempo en minutos
    int diferenciaEnMinutos = fechaActual.difference(fechaInicio).inMinutes;
    String diferenceTxt = "";
    //print("diferenciaEnMinutos: $diferenciaEnMinutos - ${order.ordersId} - ${order.ordersSku} - ${order.dateStart}");
    // if (diferenciaEnMinutos >= (60 * 24)) {
    //   difference = double.parse((diferenciaEnMinutos / (60 * 24)).toString()).round();
    // } else
    if (diferenciaEnMinutos > 60) {
      int differneceCalculate = double.parse((diferenciaEnMinutos / 60).toString()).round();
      if (differneceCalculate >= 24) {
        diferenceTxt = "${differneceCalculate ~/ 24} d";
      } else if (differneceCalculate < 24) {
        diferenceTxt = "$differneceCalculate h";
      }
    } else {
      diferenceTxt = "$diferenciaEnMinutos m";
    }

    return diferenceTxt;
  }
}

class OrdersProcesed {
  int ordersId;
  int numLineProcessed;
  OrdersProcesed({required this.ordersId, required this.numLineProcessed});
}
