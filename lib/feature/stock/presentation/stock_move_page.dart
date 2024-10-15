import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:piking/feature/stock/data/remote/response/products_origin_response.dart';
import 'package:piking/feature/stock/presentation/stock_details.dart';
import 'package:provider/provider.dart';

import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';

class StockMovePage extends StatefulWidget {
  const StockMovePage({super.key, required this.idcliente});
  final int idcliente;

  @override
  State<StockMovePage> createState() => _StockMovePageState();
}

class _StockMovePageState extends State<StockMovePage> {
  TextEditingController eanController = TextEditingController();
  bool navegateBetweenwindow = false;
  bool emptyList = false;
  List windows = [];
  List<ProductsLocationEntity> productsLocationList = [];
  late LocationResponseEntity locationResponse = LocationResponse.empty();
  String multiEan = "";
  final resultPageBack = "";
  List<int> productsIdProcessed = [];
  final FocusNode _focusNode = FocusNode();

  var productsLocationRepository = di.get<ProductsLocationRepository>();

  @override
  initState() {
    super.initState();
    log("Init STATE");
    
  }
  _navegateToDetails(LocationResponse locationResponse) async{
    final resultPageBack = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockDetails(locationResponse: locationResponse)),
    );
  }

  Widget _startPage(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return Consumer<ProductsLocationProvider>(
      builder: (context, productsLocationProvider, child) {
        //log("productsLocationProvider.showPopup: ${productsLocationProvider.showPopup}");

        return Scaffold(
          body: Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 60,
                        maxWidth: 300
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          focusNode: _focusNode,
                          controller: eanController,
                          decoration: InputDecoration(
                            labelText: 'Ean',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  eanController.clear(); // Limpiar el texto
                                  productsLocationProvider.showPopup = false;
                                  productsLocationProvider.showButton = false;
                                  setState(() {
                                    emptyList = true;
                                  });
                                  FocusScope.of(context).requestFocus(_focusNode);
                                  
                                });
                              },
                            )
                          ),
                          onChanged: (value) async {
                            log(value);
                            if(value.length > 12){
                              productsLocationProvider.locationEan(value, 0);
                              setState(() {
                                emptyList = false;
                              });
                              if(productsLocationProvider.productsMultiEanList.length > 1){
                                setState(() {
                                  multiEan = "multiEan";
                                });
                              }
                              locationResponse = productsLocationProvider.locationsReponse;
                              //log("sowPoup: ${productsLocationProvider.showPopup}");
                              // if(!productsLocationProvider.showPopup && productsLocationProvider.productsMultiEanList.length == 0){
                              //   final resultPageBack = await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(builder: (context) => StockDetails(locationResponse: locationResponse)),
                              //   );
                              //   log("resultPageBack: $resultPageBack");

                               
                              //   if(resultPageBack != "" && multiEan == "multiEan"){                                  
                              //     productsLocationProvider.locationEan(eanController.text, "");
                              //   }
                              // }
                              //if(resultPageBack != )
                             } 
                           
                          },
                        ),
                      ),
                    )
                  ],
                ),
                if (productsLocationProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  if (productsLocationProvider.showPopup)
                    _multiEan(productsLocationProvider, emptyList) 
                  else 
                    if(productsLocationProvider.showButton)
                      _unicProduct(productsLocationProvider)
                      //_butonWidget(productsLocationProvider, multiEan) 
                    else
                      Text(""),
          
            ]),
          ),
        );
      },  
    );

  }
  Widget _unicProduct(ProductsLocationProvider productsLocationProvider){
    return SingleChildScrollView(
      child:  Column(children: [
        GestureDetector(
          onTap: () {
            print('Clic en Card');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockDetails(locationResponse: productsLocationProvider.locationsReponse)),
            );
            // String ean = element.eanRef.split(";")[0].split("|")[0];
            // productsLocationProvider.locationEan(ean, element.productsId);
          },
          child: Card(
            child: Padding(
              padding:  const EdgeInsets.all(8.0),
              child:  Column(children: [
                Row(children: [
                  Text(productsLocationProvider.locationsReponse.locationOrigin.productsLocations!.first.productsSku!)
                ],),
                 Row(children: [
                  Text(productsLocationProvider.locationsReponse.locationOrigin.productsLocations!.first.productsName!)
                ],), 
                Row(children: [
                  Text(productsLocationProvider.locationsReponse.locationOrigin.productsLocations!.first.reference!)
                ],)
              ])
            )
          ),
        )


      ])
    );
  }

  Widget _butonWidget(ProductsLocationProvider productsLocationProvider, String multiEann) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Acción a realizar al presionar el botón
  
                      final resultPageBack = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StockDetails(locationResponse: productsLocationProvider.locationsReponse)),
                      );
                      bool multiEan = resultPageBack['multiEan'] ?? false;
                      int productsId = resultPageBack['productsId'] ?? 0;
                      log("resultPageBack button: $resultPageBack - $multiEan");
                      if(multiEan){
                        setState(() {
                          productsIdProcessed.add(productsId);
                        });
                        productsLocationProvider.locationEan(eanController.text, 0);
                      }
                    },
                    child: Text('VER'),
                  ),
                ),
            ]
          );
    
  }
  Widget _multiEan(ProductsLocationProvider productsLocationProvider, bool emptyList){
    List<GestureDetector> multiEanProducts = [];
    if(productsLocationProvider.showPopup){
      log("_multiEan emptyList popup: $emptyList");
      if(!emptyList){
        productsLocationProvider.productsMultiEanList.forEach((element) {
          
          multiEanProducts.add(
            GestureDetector(
              onTap: () {
                print('Clic en Card');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockDetails(locationResponse: element.details!)),
                );
                // String ean = element.eanRef.split(";")[0].split("|")[0];
                // productsLocationProvider.locationEan(ean, element.productsId);
              },
              child: Card(
                color: productsIdProcessed.contains(element.productsId) ? Colors.lightGreen: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Row(
                      children: [
                        Text(element.productsSku)
                      ]
                    ),
                    Row(
                      children: [
                        Text(element.productsName)
                      ]
                    ),
                    Row(
                      children: [
                        Text(element.eanRef)
                      ]
                    ),
                  ])
                )
              ),
            )
          );
        });
      }
    }
    return SingleChildScrollView(
      child:  Column(children: multiEanProducts)
    );
  }
   popup_stock_remove(context) async {
    bool result_showDialog = await showDialog(
          context: context,
          builder: (BuildContext context) {
            // ignore: deprecated_member_use
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                //log("onPopInvoked: $didPop");
              },
              child: AlertDialog(
                title: const Text('Atención'),
                content: const Text(
                  'Este Picking NO esta completo, \n¿¿Estas seguro lo quieres finalizar??',
                  style: TextStyle(color: Colors.red),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'SI',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onPressed: () async {
                      if (kDebugMode) {
                        print("Picking Incompleto");
                      }
                      String note =
                          "El usuario  nombre:  cerro este picking  incompleto";

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('NO', style: TextStyle(fontSize: 20.0)),
                    onPressed: () async {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, true);
                      return;
                    },
                  ),
                ],
              ),
            );
          },
        );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: widget.idcliente, title: "Ubicar", onActionPressed: () {}),
        body: Center(child: _startPage(context)),
        );
  }
}
class CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Personaliza el comportamiento aquí
    print('Una ruta fue eliminada de la pila');
  }
}