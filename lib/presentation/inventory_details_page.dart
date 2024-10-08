import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/data/dto/inventoryDto.dart';
import 'package:piking/domain/model/inventory.dart';
import 'package:piking/domain/response/inventory_response.dart';
import 'package:piking/domain/repository/inventory_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/vars.dart';

class InventoryDetailPage extends StatefulWidget {
  final Inventory product;
  const InventoryDetailPage({super.key, required this.product});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Inventory product;
  TextEditingController location = TextEditingController();
  TextEditingController ean = TextEditingController();
  TextEditingController productsQuantity = TextEditingController();

  var inventoryRepository = di.get<InventoryRepository>();

  @override
  initState() {
    super.initState();
    product = widget.product;
    location.text = product.location!;
    ean.text = product.ean!;
    productsQuantity.text = product.productsQuantity!;
  }

  _showMyDialog(BuildContext context, String? message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Respuesta inventario'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("$message"),
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
    return Scaffold(
      appBar:
          CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: PickingVars.IDCLIENTE, title: "Producto", onActionPressed: () {}),
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
                    InventoryResponse inventoryResponse = await inventoryRepository.saveInventory(
                        PickingVars.IDCLIENTE, //
                        InventoryDto(
                            location: location.text, //
                            ean: ean.text,
                            productsQuantity: productsQuantity.text));
                    if (inventoryResponse.status) {
                      // ignore: use_build_context_synchronously
                      _showMyDialog(context, inventoryResponse.message);
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
