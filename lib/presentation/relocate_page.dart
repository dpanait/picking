import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/relocate.dart';
import 'package:piking/domain/response/relocate_response.dart';
import 'package:piking/domain/repository/relocate_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/presentation/shared/menu.dart';

class RelocatePage extends StatefulWidget {
  final int idcliente;
  const RelocatePage({super.key, required this.idcliente});

  @override
  State<RelocatePage> createState() => _RelocatePageState();
}

class _RelocatePageState extends State<RelocatePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController location = TextEditingController();
  TextEditingController ean = TextEditingController();
  TextEditingController productsQuantity = TextEditingController();
  TextEditingController newLocation = TextEditingController();

  var relocateRepository = di.get<RelocateRepository>();

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
      key: scaffoldKey,
      drawer: MenuDrawer(idcliente: widget.idcliente),
      appBar: CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: widget.idcliente, title: "Reubicar", onActionPressed: () {}),
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
                height: 10,
              ),
              TextField(
                controller: newLocation,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Localización nueva',
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
                    RelocateResponse relocateResponse = await relocateRepository.saveRelocate(
                        widget.idcliente,
                        Relocate(
                            location: location.text, //
                            ean: int.parse(ean.text),
                            productsQuantity: int.parse(productsQuantity.text),
                            newLocation: int.parse(newLocation.text)));
                    //await _save_move_products(location.text, int.parse(ean.text), int.parse(productsQuantity.text), int.parse(newLocation.text));
                    if (relocateResponse.status) {
                      // ignore: use_build_context_synchronously
                      _showMyDialog(context, relocateResponse.message);
                      location.text = "";
                      ean.text = "";
                      productsQuantity.text = "";
                      newLocation.text = "";
                      // 11100000000614 8435579742037
                    } else {
                      // ignore: use_build_context_synchronously
                      _showMyDialog(context, relocateResponse.message);
                    }
                  },
                  child: const Text('Mover'),
                ),
              ),
            ]),
          )),
    );
  }
}
