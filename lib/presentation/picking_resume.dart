import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/domain/model/internal_note.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';
import 'package:piking/domain/provider/process_picking_provider.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';
import 'package:piking/domain/repository/process_picking_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/picking_list_page.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/vars.dart';
import 'package:provider/provider.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class PickingResume extends StatefulWidget {
  PickingResume(
      {super.key,
      required this.ordersProducts,
      required this.ordersSku,
      required this.pageController,
      required this.pickingCode,
      required this.callback,
      required this.internalNotes});
  late List<OrdersProducts> ordersProducts;
  late String ordersSku;
  late PageController pageController;
  late List<String> pickingCode;
  late List<InternalNotes> internalNotes;
  late VoidCallback callback;

  @override
  State<PickingResume> createState() => _PickingResumeState();
}

class _PickingResumeState extends State<PickingResume> {
  //List<Widget> cardsItems = [];
  Color? colorCard = const Color.fromARGB(255, 2, 135, 71);
  Color? colorText = Colors.white;
  bool isLoaded = false;
  late List<OrdersProducts> ordersProducts = [];
  late String ordersSku = "";
  late PageController pageController;
  late List<String> pickingCode;
  TextEditingController pickingEditCode = TextEditingController();
  final _notes = TextEditingController();
  late VoidCallback callback;
  // remote data
  var pickingDetailsRepository = di.get<PickingDetailsRepository>();
  // local data
  var productRepository = di.get<ProductRepository>();
  //process picking
  var processPickingRepository = di.get<ProcessPickingRespository>();
  String ordersId = "";
  Timer? _debounceTimer;
  FocusNode focusPickingCodeController = FocusNode();
  bool _isDialogShowing = false;
  late List<InternalNotes> internalNotes = [];

  //var ordersId = widget.orders.ordersId; //products[0].ordersId;
  //for (var i = 0; i < 10; i++) {

  //}
  @override
  void initState() {
    super.initState();
    ordersProducts = widget.ordersProducts;
    ordersSku = widget.ordersSku;
    pageController = widget.pageController;
    pickingCode = widget.pickingCode;
    callback = widget.callback;
    ordersId = widget.ordersProducts[0].ordersId;
    internalNotes = widget.internalNotes;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processPickingProvider = Provider.of<ProcessPickingProvider>(context);
    var isNotComplete = ordersProducts.any((element) => element.piking == "0");
    List<Widget> cardsItems = [];
    List<OrdersProducts> ordersProductsWhite = [];
    List<OrdersProducts> ordersProductsYellow = [];
    List<OrdersProducts> ordersProductsGreen = [];
    List<OrdersProducts> finalOrdersProducts = [];
    String completed = "LINEAS COMPLETADAS";
    int numGreenProducts = 0;
    String partials = "LINEAS INCOMPLETAS";
    int numPartialProducts = 0;
    String incomplets = "LINEAS SIN LEER";
    int numIncompletsProducts = 0;
    List<Widget> widgetInternalNotes = [];
    checkIfPickingTaked(processPickingProvider, ordersId);

    if (internalNotes.isNotEmpty) {
      for (var item in internalNotes) {
        widgetInternalNotes.add(Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            Expanded(
              child: Text(
                "${item.date} (${item.adminName}) : ${item.note}",
                style: const TextStyle(color: Colors.red),
              ),
            )
          ],
        ));
      }
    }
    cardsItems.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: widgetInternalNotes),
    ));

    ordersProductsGreen =
        ordersProducts.where((obj) => double.parse(obj.productsQuantity.toString()).round() == double.parse(obj.quantityProcessed.toString()).round()).toList();
    ordersProductsYellow = ordersProducts
        .where((obj) => (double.parse(obj.quantityProcessed.toString()).round() > 0 &&
            double.parse(obj.productsQuantity.toString()).round() > double.parse(obj.quantityProcessed.toString()).round()))
        .toList();
    ordersProductsWhite = ordersProducts.where((obj) => double.parse(obj.quantityProcessed.toString()).round() == 0).toList();

    if (ordersProductsWhite.isNotEmpty) {
      finalOrdersProducts.addAll(ordersProductsWhite);
    }

    if (ordersProductsYellow.isNotEmpty) {
      finalOrdersProducts.addAll(ordersProductsYellow);
    }

    if (ordersProductsGreen.isNotEmpty) {
      finalOrdersProducts.addAll(ordersProductsGreen);
    }
    //completadas
    completed += " ${ordersProductsGreen.length}";
    for (OrdersProducts item in ordersProductsGreen) {
      //print("Item: ${item.productsQuantity}");
      numGreenProducts += double.parse(item.productsQuantity.toString()).round();
    }
    completed += " ($numGreenProducts productos)";
    cardsItems.add(//
        Container(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(completed),
            ))); //insert(0, elemt)

    // parciales
    partials += " ${ordersProductsYellow.length}";
    for (OrdersProducts item in ordersProductsYellow) {
      //print("Item: ${item.productsQuantity}");
      numPartialProducts += double.parse(item.quantityProcessed.toString()).round();
    }
    partials += " ($numPartialProducts productos)";
    cardsItems.add(//
        Container(
            color: Colors.amber,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(partials),
            ))); //

    //incompletas
    incomplets += " ${ordersProductsWhite.length}";
    for (OrdersProducts item in ordersProductsWhite) {
      //print("Item: ${item.productsQuantity}");
      numIncompletsProducts += double.parse(item.productsQuantity.toString()).round();
    }
    incomplets += " ($numIncompletsProducts productos)";
    cardsItems.add(//
        Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(incomplets),
            )));

    for (var product in finalOrdersProducts) {
      var productsQuantity = double.parse(product.productsQuantity!).round();
      var quantityProcessed = double.parse(product.quantityProcessed!).round();

      if (quantityProcessed < productsQuantity) {
        colorCard = const Color.fromARGB(255, 255, 193, 7);
        colorText = const Color.fromARGB(255, 54, 54, 54);
      }
      if (quantityProcessed == 0) {
        colorCard = Colors.white;
        colorText = const Color.fromARGB(255, 54, 54, 54);
      }
      cardsItems.add(Center(
        child: GestureDetector(
          onTap: () {
            int index = ordersProducts.indexOf(product);
            if (index != -1) {
              //print("Index: $index - ${product.barcode}");
              Navigator.pop(context, index);
            }
          },
          child: Card(
              elevation: 10,
              shadowColor: Colors.black,
              color: colorCard,
              surfaceTintColor: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StyledText(
                            text: '<bold>Sku:</bold> ${product.productsSku ?? ""}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                            style: TextStyle(color: colorText),
                          ),
                          StyledText(
                            text: '<bold> Ref:</bold> ${product.referencia}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                            style: TextStyle(color: colorText),
                          ),
                          StyledText(
                            text:
                                '<bold> Ud:</bold> ${double.parse(product.quantityProcessed.toString()).round() ?? ""} <bold>de: </bold> ${double.parse(productsQuantity.toString()).round()}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                            style: TextStyle(color: colorText),
                          ),
                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        StyledText(
                          text: '<bold>Ean:</bold> ${product.barcode}',
                          tags: {
                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                          },
                          style: TextStyle(color: colorText),
                        ),
                      ]),
                      //${product.productsName!.length > 79 ? product.productsName!.substring(0, 80) + '...' : product.productsName}
                      Row(
                        children: [
                          SizedBox(
                            width: 340.0,
                            height: 30.0,
                            child: StyledText(
                              text: '<bold>Nombre:</bold> ${product.productsName}',
                              tags: {
                                'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                              },
                              style: TextStyle(color: colorText),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 340.0,
                            height: 30.0,
                            child: StyledText(
                              text: '<text>Loc:</text> <bold>${product.location}</bold>',
                              tags: {
                                'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                                'text': StyledTextTag(style: const TextStyle(fontSize: 18.0))
                              },
                              style: TextStyle(color: colorText),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StyledText(
                            text: '<bold>Serie/Lote:</bold> ${product.serieLote}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                            style: TextStyle(color: colorText),
                          ),
                        ],
                      )
                    ],
                  ))),
        ),
      ));
      colorCard = const Color.fromARGB(255, 2, 135, 71);
      colorText = Colors.white;
    }
    cardsItems.add(SizedBox(
      height: 190,
      child: Column(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      if (pickingCode.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.red,
                              title: const Text('Atención'),
                              content: const Text(
                                '¿¿ Estas seguro quieres borrar este Codigo??',
                                style: TextStyle(color: Colors.white, fontSize: 24.0),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('SI'),
                                  onPressed: () async {
                                    for (var product in finalOrdersProducts) {
                                      await productRepository.updatePickingCode(int.parse(product.ordersProductsId), "");
                                    }
                                    setState(() {
                                      pickingCode = [];
                                      pickingEditCode.text = "";
                                    });
                                    focusPickingCodeController.requestFocus();
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text('NO'),
                                  onPressed: () async {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.clear)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: Text(pickingCode.join(',')),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: TextField(
                focusNode: focusPickingCodeController,
                // readOnly: readOnly,
                // showCursor: true,
                //autofocus: autofocus,
                keyboardType: TextInputType.number,
                controller: pickingEditCode,
                decoration: InputDecoration(
                  labelText: 'Cod: Picking',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        pickingEditCode.clear();
                        //pickingCode = [];
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  //print("value: $value");
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
                    String pickCode = value; //getPickingCode(value).toString();
                    if (pickCode != "" && !pickingCode.contains(pickCode)) {
                      InserPickingCodeResponse inserPickingCodeResponse = await processPickingProvider.insertPickingCode(pickCode, ordersId);
                      if (inserPickingCodeResponse.status) {
                        setState(() {
                          pickingCode.add(pickCode);
                        });
                      } else {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.red,
                              title: const Text(
                                'Asignación codígo picking',
                                style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                              ),
                              content: Text(
                                inserPickingCodeResponse.message,
                                style: TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle: Theme.of(context).textTheme.bodyLarge,
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Cerrar',
                                    style: TextStyle(color: Color.fromARGB(255, 248, 248, 250), fontSize: 20.0),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        focusPickingCodeController.requestFocus();
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "El codígo picking ya esta asignado a este producto",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 10, //
                          backgroundColor: const Color.fromARGB(255, 250, 2, 2),
                          textColor: const Color.fromARGB(255, 184, 183, 183),
                          fontSize: 16.0);
                      focusPickingCodeController.requestFocus();
                    }
                  });
                },
                onEditingComplete: () {
                  //print("PickingCode: ${pickingEditCode.text}");
                  // setState(() {
                  //   String pickCode = pickingEditCode.text;
                  //   //getPickingCode(pickingEditCode.text).toString();
                  //   if (!pickingCode.contains(pickCode)) {
                  //     pickingCode.add(pickCode);
                  //   }
                  // });
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /*ElevatedButton(
                  onPressed: () {
                    //Navigator.pop(context);

                    /*for (var i = 0; i < products.length; i++) {
                              if (firstTime[i]['value'] == true) {
                                var product = products[i];
                                var productQuantity =
                                    double.parse(product.productsQuantity!).round();
                                _setProcesedQuantity(
                                    product.ordersProductsId!, productQuantity);
                              }
                            }*/

                    //_savePicking();
                    callback();
                    Navigator.pop(context);
                  },
                  child: const Text('Picking'),
                ),*/
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Notas'),
                          content: TextField(
                            keyboardType: TextInputType.text,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Actualizar la variable 'notes'
                              _notes.text = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Guardar'),
                              onPressed: () async {
                                // if (kDebugMode) {
                                //   print("Note: ${_notes.text}");
                                // }
                                await pickingDetailsRepository.saveNote(_notes.text, ordersId);

                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
          //_pagination()
        ],
      ),
    ));

    //super.build(context);
    return Scaffold(
      appBar: CustomAppBar(
          icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: PickingVars.IDCLIENTE, title: "Listado de pickings", onActionPressed: () {}),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: cardsItems,
                  ),
                ),
              ),
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  //alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 40.0,
                    color: const Color.fromARGB(255, 23, 144, 243),
                    onPressed: () {
                      //pageController.previousPage(duration: Durations.medium1, curve: Curves.bounceIn);
                      Navigator.pop(context);
                    },
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 2.0,
                    child: Text(
                      ordersSku,
                      style: const TextStyle(color: Color.fromARGB(255, 23, 144, 243), fontSize: 25.0),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      var isOnline = await InternetConnectionChecker().hasConnection;
                      if (isOnline) {
                        //_savePicking();
                        if (pickingCode.isEmpty) {
                          // ignore: use_build_context_synchronously
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Atención'),
                                content: const Text(
                                  'Este Picking NO tiene codigo de Picking, \n¿¿ Estas seguro que lo quiere Completar sin Codigo??',
                                  style: TextStyle(color: Colors.red),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('SI'),
                                    onPressed: () async {
                                      // if (kDebugMode) {
                                      //   print("Note: ${_notes.text}");
                                      // }
                                      await pickingDetailsRepository.saveNoteNonePickingCode(ordersId);
                                      callback();
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('NO'),
                                    onPressed: () async {
                                      // if (kDebugMode) {
                                      //   print("Note: ${_notes.text}");
                                      // }
                                      focusPickingCodeController.requestFocus();
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          callback();
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, pickingCode);
                        }
                      } else {
                        // ignore: use_build_context_synchronously
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.red,
                                title: const Text('Atención'),
                                content: const Text(
                                  'No tienes conexión a internet no se pude procesar el picking',
                                  style: TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  // TextButton(
                                  //   child: const Text('SI'),
                                  //   onPressed: () async {
                                  //     // if (kDebugMode) {
                                  //     //   print("Note: ${_notes.text}");
                                  //     // }
                                  //     await pickingDetailsRepository.saveNoteNonePickingCode(ordersId);
                                  //     callback();
                                  //     // ignore: use_build_context_synchronously
                                  //     Navigator.pop(context);
                                  //   },
                                  // ),
                                  TextButton(
                                    child: const Text('Cerrar'),
                                    onPressed: () async {
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: const Text('Picking completo'),
                  ),
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: IconButton(
                //     icon: const Icon(Icons.arrow_forward_ios),
                //     iconSize: 40.0,
                //     color: const Color.fromARGB(255, 23, 144, 243),
                //     onPressed: () {
                //       pageController.nextPage(duration: Durations.medium1, curve: Curves.bounceIn);
                //     },
                //   ),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }

  // con esta funcion comporbamos si mientras hacemos el picking alquien lo ha cojido
  checkIfPickingTaked(ProcessPickingProvider processPickingProvider, String ordersId) {
    //log("Llamamos a la funcion para ver quien tiene el picking");
    processPickingProvider.checkTakePicking(ordersId).then((whoOwnsPickingStatus) async {
      //print("processPickingProvider value: $whoOwnsPickingStatus - $_isDialogShowing");
      if (!_isDialogShowing) {
        //print("processPickingProvider.whoOwnsPickingStatus:  ${processPickingProvider.whoOwnsPickingStatus}");
        if (whoOwnsPickingStatus) {
          _isDialogShowing = true;
          if (mounted) {
            // ignore: use_build_context_synchronously
            bool? resultTakePicking = await showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) {
                    //log("heckIfPickingTake onPopInvoked: $didPop");
                  },
                  child: AlertDialog(
                    backgroundColor: Colors.red,
                    title: const Text(
                      'Atencion',
                      style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                    ),
                    content: /*Text(
                    "El usuario ${processPickingProvider.whoTakePicking.administratorsName} a las ${processPickingProvider.whoTakePicking.dateUpdate} te ha quitado el PICKING, ¿que quieres hacer? \nNota: Si sales se pierde todo lo que llevas, contacta con tu compañero si hay algun problema.",
                    style: const TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                  ),*/
                        OverflowBar(
                      children: [
                        Text(
                          "El usuario ${processPickingProvider.whoTakePicking.administratorsName} a las ${processPickingProvider.whoTakePicking.dateUpdate} te ha quitado el PICKING, ¿que quieres hacer? \nNota: Si sales se pierde todo lo que llevas, contacta con tu compañero si hay algun problema.",
                          style: const TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('SALIR'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('RECUPERAR'),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );

            //print("resultTakePicking: $resultTakePicking");
            if (resultTakePicking != null && resultTakePicking) {
              processPickingProvider.takePicking(ordersId);
              processPickingProvider.whoOwnsPickingStatus = false;
              //_isDialogShowing = false;
            } else if (resultTakePicking != null && !resultTakePicking) {
              processPickingProvider.leavePicking(ordersProducts);
              //_isDialogShowing = false;
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PickingListPage(idcliente: PickingVars.IDCLIENTE), // Navigate to another page
                ),
              );
            } else {
              //_isDialogShowing = false;
            }
            _isDialogShowing = false;
          }
        }
      }
    });
  }

  void _savePicking() async {
    // ignore: unrelated_type_equality_checks
    var isNotComplete = ordersProducts.any((element) => element.piking == "0");
    // print("SavePicking");
    // return;
    List readedProducts = [];
    List readedLocations = [];
    String pickingCodeString = "";
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      for (var item in ordersProducts) {
        // boramos los productos de la base de datos local si se ha hecho el picking en totalidad
        var entityProduct = await productRepository.getProductById(int.parse(item.ordersProductsId));

        // if (kDebugMode) {
        print("Piking: ${entityProduct?.picking}");
        //   print("entityProduct: ${entityProduct?.productsQuantity}- ${entityProduct?.quantityProcessed}");
        //   print("Product: ${item.ordersProductsId} - ${item.quantityProcessed} - ${entityProduct?.productsQuantity == entityProduct?.quantityProcessed}");
        // }

        if (!isNotComplete &&
            entityProduct?.picking != null &&
            double.parse(entityProduct!.productsQuantity).round() == double.parse(entityProduct.quantityProcessed).round()) {
          // print("Delete from local: ${double.parse(entityProduct!.productsQuantity).round() == double.parse(entityProduct!.quantityProcessed).round()}");
          productRepository.deleteProduct(entityProduct);
          if (!readedProducts.contains(item.ordersProductsId)) {
            readedProducts.add(item.ordersProductsId);
          }
          if (!readedLocations.contains(item.locationId)) {
            readedLocations.add(item.locationId);
          }
        }
      }
      // if (kDebugMode) {
      //   print("Series/LOtes: ${jsonEncode(serieLotes)}");
      // }
      pickingCode.removeWhere((element) => element.isEmpty);
      if (pickingCode.length == 1) {
        pickingCodeString = pickingCode[0];
      } else {
        pickingCodeString = pickingCode.join(",");
      }
      pickingDetailsRepository.savePicking(ordersProducts, pickingCodeString);
      //insertamos datos para finalizar el picking
      PickingProcess pickingProcess = PickingProcess(
          ordersId: ordersProducts[0].ordersId,
          administratorsSku: PickingVars.USERSKU,
          readedProducts: (readedProducts.length).toString(),
          readedLocations: (readedLocations.length).toString(),
          dateStart: "",
          dateEnd: "",
          pickingCode: pickingCodeString);

      processPickingRepository.endPickingProcess(pickingProcess);
      widget.callback();
      // ignore: use_build_context_synchronously
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => PickingListPage(idcliente: PickingVars.IDCLIENTE), // Navigate to another page
      //   ),
      // );
    } else {
      // Fluttertoast.showToast(
      //     msg: "Error: No tiene conexion a internet",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 10, //
      //     backgroundColor: const Color.fromARGB(255, 184, 183, 183),
      //     textColor: const Color.fromARGB(255, 250, 2, 2),
      //     fontSize: 16.0);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: const Text(
              'Internet conection',
              style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
            ),
            content: const Text(
              "No hay conexion a internet.",
              style: TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Color.fromARGB(255, 0, 45, 248)),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    // guardamos la serie lote
    //serieLoteRepository.saveSerieLote(int.parse(widget.orders.ordersId.toString()), serieLotes);

    // ignore: use_build_context_synchronously
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PickingListPage(idcliente: PickingVars.IDCLIENTE), // Navigate to another page
      ),
    );
    //Navigator.pop(context, "reload");
    return;
  }

  Future<bool> checkInternetConnection() async {
    var isOnline = await InternetConnectionChecker().hasConnection;
    return isOnline;
  }

  int getPickingCode(String input) {
    // Buscar la posición del primer "0" en el string
    int firstZeroPosition = input.indexOf('0');

    // Si se encuentra el "0", contar la cantidad de ceros que siguen
    if (firstZeroPosition != -1) {
      int cerosDetrasDeDos = int.parse(input.substring(firstZeroPosition + 1));
      return cerosDetrasDeDos;
    } else {
      // Si no se encuentra el "2", devuelve 0
      return 0;
    }
  }
}
