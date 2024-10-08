import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:piking/domain/model/objects.dart';

class SerieLotePageBack extends StatelessWidget {
  late int ordersProductsId = 0;
  late String productsSku = "";
  late SerieLotes seriesLote;
  SerieLotePageBack({super.key, required this.ordersProductsId, required this.productsSku, required this.seriesLote});

  TextEditingController numberTextFieldController = TextEditingController();
  int numberOfFields = 0;
  List<TextEditingController> groupSerieLoteControllers = [];
  List<TextEditingController> serieLoteProductControllers = [];
  String groupSerie = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> rowsField = [];
    if (kDebugMode) {
      print("Series: $seriesLote");
    }
    if (seriesLote.serieLoteItem.isNotEmpty) {
      numberOfFields = seriesLote.serieLoteItem.length;
      groupSerieLoteControllers = List.generate(
        numberOfFields,
        (index) => TextEditingController(),
      );
      serieLoteProductControllers = List.generate(
        numberOfFields,
        (index) => TextEditingController(),
      );

      if (kDebugMode) {
        print("numberOfFields: $numberOfFields");
        print("group: ${seriesLote.serieLoteItem[0].serieLoteGroup}");
        print("code: ${seriesLote.serieLoteItem[0].serieLote}");
      }
    }
    //print("group: ${seriesLote['serieLotes'][0]}");
    //print("code: ${seriesLote['serieLotes'][1]}");
    for (var i = 0; i < numberOfFields; i++) {
      rowsField.add(Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                    controller: groupSerieLoteControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Serie/Lote grupo ${i + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      groupSerieLoteControllers[i].text = value;
                      groupSerie = value;
                    })),
          ),
          Expanded(
            flex: 3,
            child: TextField(
                controller: serieLoteProductControllers[i],
                decoration: InputDecoration(
                  labelText: 'Serie/Lote ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  serieLoteProductControllers[i].text = value;
                  groupSerieLoteControllers[i].text = groupSerie;
                }),
          ),
          Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (kDebugMode) {
                    print("Add button clicked");
                  }
                  numberOfFields++;
                },
              ))
        ],
      ));
      if (seriesLote.serieLoteItem.isNotEmpty) {
        groupSerieLoteControllers[i].text = seriesLote.serieLoteItem[i].serieLoteGroup;
        serieLoteProductControllers[i].text = seriesLote.serieLoteItem[i].serieLote;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Serie/Lote: $productsSku",
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Center(
              child: Text("Serie/Lote"),
            ),
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: numberTextFieldController,
                  decoration: const InputDecoration(labelText: 'Ingresar el numero de filas'),
                  onChanged: (value) {
                    if (kDebugMode) {
                      print("value: $value");
                      print("screenWidth: ${context.screenWidth}");
                    }

                    seriesLote.ordersProductsId = "";
                    seriesLote.serieLoteItem = [];
                    //setState(() {
                    numberOfFields = value != "" ? int.parse(value) : 1;

                    groupSerieLoteControllers = List.generate(
                      numberOfFields,
                      (index) => TextEditingController(text: groupSerie),
                    );

                    //numberTextFieldController.text = value;
                    serieLoteProductControllers = List.generate(numberOfFields, (index) => TextEditingController());
                    //});
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: rowsField,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                List<Map<String, dynamic>> gropuSerieLotes = [];
                for (int i = 0; i < numberOfFields; i++) {
                  if (kDebugMode) {
                    print('Campo $i: ${groupSerieLoteControllers[i].text}');
                  }
                  if (groupSerieLoteControllers[i].text != "") {
                    gropuSerieLotes.add({'value': groupSerieLoteControllers[i].text});
                  }
                }
                List<Map<String, dynamic>> serieLotes = [];
                for (int i = 0; i < numberOfFields; i++) {
                  if (kDebugMode) {
                    print('Campo $i: ${serieLoteProductControllers[i].text}');
                  }
                  if (serieLoteProductControllers[i].text != "") {
                    serieLotes.add({'value': serieLoteProductControllers[i].text});
                  }
                }
                List<List<Map>> params = [];
                params.add(gropuSerieLotes);
                params.add(serieLotes);

                // Enviar datos a Screen1 al volver
                Navigator.pop(context, params);
              },
              child: const Text('Guardar Serie/lotes'),
            ),
          ]),
        ),
      ),
    );
  }
}
