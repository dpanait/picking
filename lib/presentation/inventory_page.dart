import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/data/dto/inventoryDto.dart';
import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/model/inventory.dart';
import 'package:piking/domain/response/inventory_response.dart';
import 'package:piking/domain/response/location_response.dart';
import 'package:piking/domain/repository/inventory_repository.dart';
import 'package:piking/domain/repository/location_repository.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/location_product_list_page.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/presentation/shared/menu.dart';
import 'package:piking/vars.dart';

class InventoryPage extends StatefulWidget {
  final int idcliente;
  const InventoryPage({super.key, required this.idcliente});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  StoreResponse storeResponse = StoreResponse(status: false);

  List<Store> stores = [];
  List<PopupMenuItem> storeItem = [];
  late String storeLabel = "Almacen";
  TextEditingController location = TextEditingController();
  TextEditingController ean = TextEditingController();
  TextEditingController productsQuantity = TextEditingController();
  bool isMultiLocationVisible = false;
  List<Inventory> productsInventory = [];

  var inventoryRepository = di.get<InventoryRepository>();
  var locationRepository = di.get<LocationRepository>();
  var storeRepository = di.get<StoreRepository>();

  postStore() async {
    storeResponse = await storeRepository.getAllStore(widget.idcliente);
    setState(() {
      storeResponse.body?.forEach((element) {
        stores.add(Store.fromJson(element.toJson()));
      });
    });
  }

  @override
  initState() {
    super.initState();
    postStore();
  }

  /*_save_inventory(location, ean, productsQuantity) async {
    InventoryDto inventory = InventoryDto(
        location: location, //
        ean: ean,
        productsQuantity: productsQuantity);
    InventoryResponse inventryResponse = await inventoryRepository.postInventory(IDCLIENTE, inventory);
    /*if(inventryResponse!.status){
      _showMyDialog(context, inventryResponse!.body ?? "");
      return true;
    }*/
    return inventryResponse;
  }*/

  _showMyDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Respuesta inventario'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    storeItem = [];
    for (var i = 0; i < stores.length; i++) {
      if (kDebugMode) {
        print("CAJASID: ${PickingVars.CAJASID}");
      }

      storeItem.add(PopupMenuItem<int>(
        value: int.parse(stores[i].cajasId!),
        child: Text(
          "${stores[i].cajasId} - ${stores[i].cajasName ?? stores[i].cajasNameY}",
          style: TextStyle(fontWeight: (PickingVars.CAJASID == int.parse(stores[i].cajasId!)) ? FontWeight.w700 : FontWeight.normal),
        ),
      ));
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: MenuDrawer(idcliente: widget.idcliente),
      appBar: CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: widget.idcliente, title: "Inventario", onActionPressed: () {}),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: location,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Localización',
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.lightBlue.shade900),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: ean,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Ean',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        if (kDebugMode) {
                          print("Search multilocations 8435579710593");
                        }
                        LocationResponse multiLocationResponse = await locationRepository.checkMultiLocations(ean.text);
                        if (multiLocationResponse.status && multiLocationResponse.inventory.length > 1) {
                          if (kDebugMode) {
                            print("multi status ${multiLocationResponse.status}");
                          }
                          setState(() {
                            isMultiLocationVisible = true;
                            //productsInventory.addAll(multiLocationResponse!.products as Iterable<Inventory>);
                            productsInventory = multiLocationResponse.inventory.toList();
                          });
                        }
                      },
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.lightBlue.shade900),
                    )),
              ),
              SizedBox(
                  child: isMultiLocationVisible == true
                      ? TextButton(
                          child: const Text("Ver los productos"),
                          onPressed: () {
                            setState(() {
                              //isMultiLocationVisible = false;
                            });
                            if (kDebugMode) {
                              print("Multilocalizaciones");
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationProductsList(products: productsInventory),
                              ),
                            );
                            //productsInventory.clear();
                          },
                        )
                      : const Center()),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: productsQuantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Cantidad',
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.lightBlue.shade900),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Localizacion: ${location.text} Ean: ${ean.text}\nproducts_cuantity: ${productsQuantity.text}");
                    }
                    InventoryResponse inventryResponse = await inventoryRepository.saveInventory(
                        PickingVars.IDCLIENTE,
                        InventoryDto(
                            location: location.text,
                            ean: ean.text,
                            productsQuantity:
                                productsQuantity.text)); //await _save_inventory(location.text, int.parse(ean.text), int.parse(productsQuantity.text));
                    if (inventryResponse.status) {
                      // ignore: use_build_context_synchronously
                      _showMyDialog(context, inventryResponse.message);
                      location.text = "";
                      ean.text = "";
                      productsQuantity.text = "";
                      // 11100000000614 8435579742037
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ]),
          )),
    );
  }
}
