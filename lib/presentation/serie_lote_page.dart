import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'package:piking/domain/model/objects.dart';

class SerieLotePage extends StatefulWidget {
  SerieLotePage({super.key, required this.ordersProductsId, required this.productsSku, required this.seriesLote});
  late int ordersProductsId;
  late String productsSku;
  late SerieLotes seriesLote;

  @override
  State<SerieLotePage> createState() => _SerieLotePageState();
}

class _SerieLotePageState extends State<SerieLotePage> {
  TextEditingController numberTextFieldController = TextEditingController();
  TextEditingController datePickerController = TextEditingController();
  int numberOfFields = 0;
  List<TextEditingController> groupSerieLoteControllers = [];
  List<TextEditingController> serieLoteProductControllers = [];
  List<TextEditingController> quantityLoteControllers = [];
  List<TextEditingController> dateLoteControllers = [];
  String groupSerie = "";
  late SerieLotes seriesLote;
  late String productsSku;
  late int ordersProductsId;

  @override
  void initState() {
    super.initState();
    seriesLote = widget.seriesLote;
    productsSku = widget.productsSku;
    ordersProductsId = widget.ordersProductsId;
  }

  _onChangeNumRow(value) {
    if (kDebugMode) {
      print("value: $value");
      print("screenWidth: ${context.screenWidth}");
    }

    // seriesLote.ordersProductsId = "";
    // seriesLote.seriesLotes = [];
    setState(() {
      numberOfFields = value != "" ? int.parse(value) : 1;

      groupSerieLoteControllers = List.generate(
        numberOfFields,
        (index) => TextEditingController(text: groupSerie),
      );

      //numberTextFieldController.text = value;
      serieLoteProductControllers = List.generate(numberOfFields, (index) => TextEditingController());
      quantityLoteControllers = List.generate(numberOfFields, (index) => TextEditingController());
      dateLoteControllers = List.generate(numberOfFields, (index) => TextEditingController());

      if (seriesLote.serieLoteItem.isNotEmpty) {
        for (var i = 0; i < numberOfFields; i++) {
          groupSerieLoteControllers[i].text = seriesLote.serieLoteItem[i].serieLoteGroup;
          serieLoteProductControllers[i].text = seriesLote.serieLoteItem[i].serieLote;
          quantityLoteControllers[i].text = seriesLote.serieLoteItem[i].quantity.toString();
          dateLoteControllers[i].text = seriesLote.serieLoteItem[i].date.toString();
        }
      }
    });
  }

  onTapFunction({required BuildContext context, required int index}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(9999, 12, 31), //DateTime.now().add(Duration(days: 30 * 5)),
      firstDate: DateTime(DateTime.now().year),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    dateLoteControllers[index].text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

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
      quantityLoteControllers = List.generate(numberOfFields, (index) => TextEditingController());
      dateLoteControllers = List.generate(numberOfFields, (index) => TextEditingController());
      if (kDebugMode) {
        print("numberOfFields: $numberOfFields");
        print("group: ${seriesLote.serieLoteItem[0].serieLoteGroup}");
        print("code: ${seriesLote.serieLoteItem[0].serieLote}");
      }
    }

    if (kDebugMode) {
      print("numberOfFields: $numberOfFields");
    }
    if (numberOfFields > 0) {
      for (var i = 0; i < numberOfFields; i++) {
        rowsField.add(Card(
          shadowColor: Colors.grey.shade300,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  flex: 1,
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
                  flex: 1,
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
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                          controller: quantityLoteControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Ud ${i + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (kDebugMode) {
                              print("quantityLoteControllers: ${quantityLoteControllers[i]} $i");
                            }
                            quantityLoteControllers[i].text = value;
                          }),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: dateLoteControllers[i],
                        readOnly: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Fecha ${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onTap: () => onTapFunction(context: context, index: i),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (kDebugMode) {
                            print("Add button clicked");
                          }
                          setState(() {
                            if (numberOfFields > -1) {
                              numberOfFields = numberOfFields - 1;
                            }

                            numberTextFieldController.text = numberOfFields.toString();
                            if (seriesLote.serieLoteItem.isNotEmpty) {
                              seriesLote.serieLoteItem.removeAt(i);
                              if (kDebugMode) {
                                print("Serie group: ${seriesLote.serieLoteItem.length}");
                              }
                            }

                            _onChangeNumRow(numberOfFields.toString());
                            // groupSerieLoteControllers = List.generate(
                            //   numberOfFields,
                            //   (index) => TextEditingController(),
                            // );
                            // serieLoteProductControllers = List.generate(
                            //   numberOfFields,
                            //   (index) => TextEditingController(),
                            // );
                          });
                        },
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        ));
        if (seriesLote.serieLoteItem.isNotEmpty) {
          //setState(() {
          groupSerieLoteControllers[i].text = seriesLote.serieLoteItem[i].serieLoteGroup;
          serieLoteProductControllers[i].text = seriesLote.serieLoteItem[i].serieLote;
          quantityLoteControllers[i].text = seriesLote.serieLoteItem[i].quantity.toString();
          dateLoteControllers[i].text = seriesLote.serieLoteItem[i].date.toString();
          //});
        }
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
            Row(children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: numberTextFieldController,
                  decoration: const InputDecoration(labelText: 'Ingresar el numero de filas'),
                  onChanged:
                      _onChangeNumRow /*(value) {
                    print("value: $value");
                    print("screenWidth: ${context.screenWidth}");
                    seriesLote.ordersProductsId = "";
                    seriesLote.seriesLotes = [];
                    setState(() {
                      numberOfFields = value != "" ? int.parse(value) : 1;

                      groupSerieLoteControllers = List.generate(
                        numberOfFields,
                        (index) => TextEditingController(text: groupSerie),
                      );

                      //numberTextFieldController.text = value;
                      serieLoteProductControllers = List.generate(numberOfFields, (index) => TextEditingController());
                    });
                  }*/
                  ,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (kDebugMode) {
                        print("Add button clicked");
                      }
                      setState(() {
                        numberOfFields++;
                        numberTextFieldController.text = numberOfFields.toString();
                        if (seriesLote.serieLoteItem.isNotEmpty) {
                          seriesLote.serieLoteItem.add(SerieLoteItem("", "", 0, ""));
                        }

                        _onChangeNumRow(numberOfFields.toString());
                        // groupSerieLoteControllers = List.generate(
                        //   numberOfFields,
                        //   (index) => TextEditingController(),
                        // );
                        // serieLoteProductControllers = List.generate(
                        //   numberOfFields,
                        //   (index) => TextEditingController(),
                        // );
                      });
                    },
                  ))
            ]),
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
                List<SerieLoteItem> serieLotesItems = [];
                for (int i = 0; i < numberOfFields; i++) {
                  if (kDebugMode) {
                    print('Campo $i: ${groupSerieLoteControllers[i].text}');
                  }
                  if (groupSerieLoteControllers[i].text != "") {
                    //gropuSerieLotes.add({'value': groupSerieLoteControllers[i].text});
                    try {
                      serieLotesItems.add(SerieLoteItem(
                          groupSerieLoteControllers[i].text, //
                          serieLoteProductControllers[i].text,
                          int.parse(quantityLoteControllers[i].text),
                          dateLoteControllers[i].text.toString()));
                    } on Exception catch (_, e) {
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  }
                }
                /* List<Map<String, dynamic>> serieLotes = [];
                for (int i = 0; i < numberOfFields; i++) {
                  print('Campo $i: ${serieLoteProductControllers[i].text}');
                  if (serieLoteProductControllers[i].text != "") {
                    serieLotes.add({'value': serieLoteProductControllers[i].text});
                  }
                }
                List<List<Map>> params = [];
                params.add(gropuSerieLotes);
                params.add(serieLotes);*/

                // Enviar datos a Screen1 al volver
                Navigator.pop(context, serieLotesItems);
              },
              child: const Text('Guardar Serie/lotes'),
            ),
          ]),
        ),
      ),
    );
  }
}
