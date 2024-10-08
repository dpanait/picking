
import 'dart:convert';
import 'dart:developer';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/shared/swipe_detector.dart';
import 'package:piking/feature/stock/data/remote/model/product_location_model.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';
import 'package:piking/feature/stock/domain/entities/products_location_response_entity.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:piking/feature/stock/data/remote/response/products_origin_response.dart';
import 'package:piking/feature/stock/domain/repository/products_location_repository.dart';
import 'package:provider/provider.dart';

import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/domain/repository/store_repository.dart';

class StockDetails extends StatefulWidget {
  StockDetails({super.key, required this.locationResponse});
  late LocationResponseEntity locationResponse;

  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {

  late LocationResponseEntity locationResponse;
  late LocationOriginEntity locationOrigin;
  late LocationZeroEntity locationZero;
  late List<ProductsLocationEntity> productsLocationOrigin = [];
  late List<ProductsLocationEntity> productsLocationZero = [];
  late List<LocationEntity> locations = [];
  bool isPopScope = false;
  bool multiEan = false;
  List<StoreEntity> stores = [];
  var storeRepository = di.get<StoreRepository>();
  var productsLocationRepository = di.get<ProductsLocationRepository>();

  @override
  initState() {
    super.initState();
    locationResponse = widget.locationResponse;
    locationOrigin = widget.locationResponse.locationOrigin;
    locationZero = widget.locationResponse.locationZero;
    productsLocationOrigin = widget.locationResponse.locationOrigin.productsLocations!;
    productsLocationZero = widget.locationResponse.locationZero.locationZero;
    locations = widget.locationResponse.locationOrigin.locations!;
    _loadStores();

  }
  _loadStores() async {
    stores = await storeRepository.getStore();
  }
  _reloadTableProducts(int  productsId) async{
    ProductsLocationResponseEntity resultLocationEan = await productsLocationRepository.locationEan("", productsId);
    if (resultLocationEan.type != "") {
      LocationResponseEntity locationResponseEntity = resultLocationEan.locationResponse;
      if(locationResponseEntity.locationOrigin.productsLocations!.isNotEmpty){
        setState(() {
          productsLocationOrigin = locationResponseEntity.locationOrigin.productsLocations!;
          productsLocationZero = locationResponseEntity.locationZero.locationZero;
          locations = locationResponseEntity.locationOrigin.locations!;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stockLocations = [];
    final productsLocationProvider = Provider.of<ProductsLocationProvider>(context, listen: false);
    log("locationOrigin.productsLocations: ${locationOrigin.productsLocations?.length} ${productsLocationOrigin.length} Stores: ${stores.length}");
  
    if (productsLocationOrigin.isNotEmpty) {
      double sinUbicar = 0;
      double quantityLocated = 0;
      List<ProductsLocationEntity> sinUbicarElements = [];
      List<ProductsLocationEntity> locatedElements = [];
      for(ProductsLocationEntity item in productsLocationOrigin){
        locatedElements.add(item);
        if(item.multiEan!){
          setState(() {
            multiEan = true;
          });
        }
      }
      
      productsLocationZero.map((e) {
        sinUbicarElements.add(e);
      });
      List<TableRow> tableRowsLocated = [];
      List<TableRow> tableRowsUnLocated = [];
      bool isLocated = false;
      bool isUnLocated = false;


      tableRowsLocated.add(
        const TableRow(
          children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('   ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              widthFactor: 1,
              child: Text('Locatión', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 40,
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1,
                widthFactor: 1,
                child: Text('Ud', style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              widthFactor: 2,
              child: Text('Almacen', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
        ])
      );

      tableRowsUnLocated.add(
          const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(0.0),
            child: Text('   ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              widthFactor: 1,
              child: Text('Ud', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              widthFactor: 2,
              child: Text('Almacen', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
        ])
      );
      
      for (ProductsLocationEntity item in productsLocationZero) {
        sinUbicar += item.productsQuantity! - item.quantity!;
      }

      for (ProductsLocationEntity item in locatedElements){
        quantityLocated += item.located!;
      }
      log("sinUbicarElements: ${productsLocationZero.length} - locatedElements: ${locatedElements.length}");

      // location zero
      //for (ProductsLocation item in productsLocationOrigin) {
      productsLocationOrigin.asMap().forEach((index, item){
        log("productsQuantity: ${item.productsQuantity} - quantity: ${item.quantity}");
        sinUbicar += item.quantity! - item.located!;

        if (index == 0) {

          stockLocations.add(GestureDetector(
            onTap: () {
              print('Clic en Card');
            },
            child: Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text("SKU: ${item.productsSku}",style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Ref: ${item.reference}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(" ${item.productsName}"))
                        ],
                      ),
                      
                    ],
                  ),
                )),
          ));
        }
        
      });

      for(ProductsLocationEntity item  in productsLocationZero){
        // productos sin ubicar
        //if (item.located! > 0) {
          //isUnLocated = true;
          String quantityUnLocated = (item.quantity! - item.located!).toString();

          if(item.quantityMax! > 0){
            quantityUnLocated += 'max ${item.quantityMax!} ud';
          }

          tableRowsUnLocated.add(
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: TextButton(
                  onPressed: () {
                    // Action to perform when the button is pressed
                    popUpLocationChange(context, item, locations);
                  },
                  child: Text('MOVER', style: TextStyle(fontSize: 12),),
                )
              ),
              
              Padding(
                padding: const EdgeInsets.all(5.0),
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: Text('$quantityUnLocated')
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: Tooltip(
                    message: "${item.cajasAlias} ${item.cajasName}",
                    showDuration: Duration(seconds: 5),
                    child: Text(
                      '${item.cajasAlias} ${item.cajasName}',
                      overflow: TextOverflow.ellipsis
                    ),
                  )
                ),
              ),
            ]),
          );
        //}
      }
      // location origin
      for( ProductsLocationEntity item in locatedElements){
        log("Item: ${item.located}");
        // produtos con localizacion
        //if (item.located! >= 0) {
        
          isLocated = true;
          String quantityLocated = (item.quantity! - item.located!).toString();
          if(item.quantityMax! > 0){
            quantityLocated += 'max ${item.quantityMax!} ud';
          }

          LocationEntity location =  locations.firstWhere((element) => element.locationsId == item.locationsId);
          String location_txt = _buildLocationString(location);

          tableRowsLocated.add(
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: PopupMenuButton(
                  icon: const Icon(Icons.settings),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Mover'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Mover a ubicación CERO'),
                    ),
                      const PopupMenuItem(
                      value: 3,
                      child: Text('Mover a ubicación CERO y QUITAR RELACIÓN'),
                    ),
                    const PopupMenuItem(
                      value: 4,
                      child: Text('Convertir en ubicación favorita'),
                    ),
                  ],
                  onSelected: (value) {
                    // Acción a realizar al seleccionar una opción
                    print("Selected value: $value");
                    if(value == 1){
                      _popupStockRemove(context, item, locations);
                      //popupStockRemove(context, item);
                    }
                    if(value == 2){
                      _popupMoveToCero(context, item);
                    }
                    if(value == 3){
                      _popUpMoveZeroUnlink(context, item);
                    }
                     if(value == 4){
                      _popUpMakeFavoriteLocation(context, item);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: Tooltip(
                    message: "${item.locationsId}",
                    showDuration: Duration(seconds: 5), 
                    child: Text(location_txt)
                  ),//Text('${totaProductsLocation[0].location}')
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: Text('${item.quantity}')
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: Tooltip(
                    message: "${item.cajasAlias} ${item.cajasName}",
                    showDuration: Duration(seconds: 5),
                    child: Text(
                      '${item.cajasAlias} ${item.cajasName}',
                      overflow: TextOverflow.ellipsis
                    ),
                  )
                ),
              ),
            ]),
          );
        
        //}
      }

      //añadimos los prooductos ubicados
      if(isLocated){
        stockLocations.add(GestureDetector(
          onTap: () {
            print('Clic en Card');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => QuantityMovePage(
            //             from: "",
            //             quantity: quantityLocated.toInt(),
            //             productsLocation: locatedElements.first,
            //           )),
            // );
          },
          child: Card(
            margin: EdgeInsets.all(6.0),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 2.0),
                        child: Center(child: Text("PRODUCTOS UBICADOS")),
                      )
                    ],
                  ),
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(0.5),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(0.7),
                      3: FlexColumnWidth(1.5),
                    },
                    children: tableRowsLocated
                  ),
                  
                ],
              ),
            )
          ),
        ));
      }

      //if(isUnLocated){

        stockLocations.add(GestureDetector(
            onTap: () {
              print('Clic en Card');
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => QuantityMovePage(
              //             from: "",
              //             quantity: sinUbicar.toInt(),
              //             productsLocation: ProductsLocation.empty(),
              //           )),
              // );
            },
            child: Card(
              margin: EdgeInsets.all(0.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 2.0),
                          child: Text("PRODUCTOS SIN UBICAR"),
                        )
                      ]
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.7),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1),
                      },
                      children: tableRowsUnLocated
                    ),
                  ],
                ),
              )),
          ));
      //}
      
    } 

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Gestión de prod. en ubicaciones"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              // Acción para el ícono de menú
              //isPopScope = true;
              Map<String, dynamic> returnPage = {
                'multiEan': multiEan,
                'productsId': productsLocationOrigin.length > 0 ? productsLocationOrigin[0].productsId : 0
              };
              Navigator.pop(context, returnPage);
            },
          ),
          actions:[ ]
        ),
        body: SafeArea(
          child: PopScope(
            canPop: isPopScope,
            onPopInvoked: (didPop){
              log("stock_detail: $didPop");
            },
            child: Center(
              child: SwipeDetector(
                onSwipeLeft: () {
                  log("Vamos a la izquerda");
                },
                onSwipeRight: () {
                  log("vamos a la derecha ");
                },
                child: Center(
                    child: Column(children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                        //
                        children: stockLocations),
                  )),
                ])),
              ),
            ),
          ),
        ));
  }
  //MOVER
  Future<void> _popupStockRemove(context, ProductsLocationEntity item, List<LocationEntity> locationOld) async {
    TextEditingController searchController = TextEditingController();
    TextEditingController skuUbicacionController = TextEditingController();
    TextEditingController quantityToMoveController = TextEditingController();

    quantityToMoveController.text = item.located.toString();

    String locationPastTxt = "";
    locationOld.forEach((element) {
    
      locationPastTxt += _buildLocationString(element) + "\t";

    });
    int numElements = 0;
    
    bool resultPopUp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return Consumer<SearchLocationProvider>(
          builder: (context, provider, child) {

            return AlertDialog(
              title: const Text('Cambiar de ubicación'),
              content: Stack(
                children: [
                  // Existing dialog content (excluding the list)
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextRow('', item.productsSku!, true),
                        _buildTextRow('', item.productsName!, false),
                        const SizedBox(height: 6),
                        _buildTextRow('','Ubicaciónes: \n(está o estuvo el producto)', false),
                        _buildTextRow('', locationPastTxt, false),
                        const SizedBox(height: 6),
                       Row(
                         children: [
                           Flexible(
                             flex: 1,
                             child: Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: TextField(
                                 controller: searchController,
                                 decoration: InputDecoration(
                                   labelText: 'Buscar ubicación(destino):',
                                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
                                   suffixIcon: IconButton(
                                     icon: Icon(Icons.clear),
                                     onPressed: () {
                                       searchController.clear(); // Limpiar el texto
                                       provider.results = [];
                                       provider.isLoading = false;
                                     },
                                   ),
                                   
                                 ),
                                 onChanged: (query){
                                   provider.searchLocation(query, item.cajasId!, item.productsId!);
                                   if(provider.results.isNotEmpty){
                                     //provider.isLoading = false;
                                     //provider.showListResult = true;
                                   }
                                 } 
                               ),
                             ),
                           ),
                           
                         ],
                       ),   
                       const SizedBox(height: 6),                      
                       _buildTextField(
                          controller: skuUbicacionController,
                          labelText: 'SKU ubicación:',
                          height: 30,
                          readOnly: true
                        ),
                       _buildTextField(
                          controller: quantityToMoveController,
                          labelText: 'Cantidad a mover:',
                          height: 50
                        ),
                      ],
                    ),
                  ),
                  // Overlay for the list (conditionally shown)
                  provider.showListResult
                    ? Positioned(
                        bottom: -30, // Position the list at the bottom
                        left: 0,
                        right: 0,
                        //top:10,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: provider.results.map((option) {
                                  String locationTxt = _buildLocationString(option);
                                  //log("locationTxt: $locationTxt");
                                  numElements++;
                                  return Flexible(
                                    flex:1,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: ListTile(
                                            dense: true,
                                            //contentPadding: const EdgeInsets.only(top: 0, bottom: -10, left: 8.0, right: 8.0), 
                                            contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                                            title: Text("${option.locationsSku}: $locationTxt", style: TextStyle(fontSize: 12)),
                                            subtitle: Text("Descripción: ${option.description}"),
                                            onTap: () {
                                              //log("onTap ListTile: ${option.locationsSku}");
                                              searchController.text = locationTxt;
                                              skuUbicacionController.text = option.locationsSku!;
                                              
                                              provider.showListResult = false;
                                              provider.selectedLocationsId = option.locationsId;
                                              provider.selectedProductsId = item.productsId!;
                                              SelectedLocation selectedLocation = SelectedLocation(option.locationsId,
                                                                                                  option.cajasId,
                                                                                                  item.productsId!,
                                                                                                  item.locationsId!,
                                                                                                  int.parse(quantityToMoveController.text)
                                                                                                );
                                              provider.selectedLocationObj = selectedLocation;
                                                        
                                            },
                                          ),
                                        ),
                                        if (provider.results.length != numElements ) Divider(),
                                      ],
                                    ),
                                  );
                                  
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                          
                      )
                    : SizedBox(),                
                  ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'MOVER',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Cerrar");
                    }
                    provider.moveToLocation(int.parse(quantityToMoveController.text));
            
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
                  child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                  onPressed: () async {
                    provider.results = [];
                    provider.showListResult = false;
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                    return;
                  },
                ),
              ],
            );
          }
        );
      },
    ).then((value) {
      return value ?? false; // Manejar el caso de cierre sin respuesta
    });

    if(resultPopUp){
      _reloadTableProducts(item.productsId!);
    };

  }

  // Mover a ubicación CERO
  Future<void> _popupMoveToCero(context, ProductsLocationEntity item) async{
    TextEditingController quantityToMoveController = TextEditingController();
    quantityToMoveController.text = item.quantity.toString();
    SelectedLocation selectedLocation = SelectedLocation(0,
                                                          item.cajasId!,
                                                          item.productsId!,
                                                          item.locationsId!,
                                                          0);

    bool resultPopUp =  await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return Consumer<ProductsLocationProvider>(
          builder: (context, provider, child) {

            return 
            AlertDialog(
              title: const Text('Mover a ubicación CERO'),
              content: SingleChildScrollView(
                child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                      _buildTextRow('', item.productsSku!, true),
                      _buildTextRow('', item.productsName!, false),
                      Divider(),
                      const SizedBox(height: 8,),
                      Row(
                        children: [
                          Flexible(
                            flex:1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: quantityToMoveController,
                                decoration: InputDecoration(
                                  labelText: 'Cantidad a mover:',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      
                                      quantityToMoveController.clear(); // Limpiar el texto
                                        
                                    },
                                  )
                                ),
                                onChanged: (value) async {
                                  log("Quantity: $value");
                                  quantityToMoveController.text = value;
                                  
                                  if(value.isNotEmpty){
                                    selectedLocation.quantity = int.parse(value);
                                  } 
                                  
                                },
                              ),
                            ),
                          )
                        ],
                       )
                     ]
                )
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'MOVER',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Cerrar");
                    }
                    selectedLocation.quantity = int.parse(quantityToMoveController.text);
                    provider.moveToZero(context, selectedLocation);
            
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
                  child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                    return;
                  },
                ),
              ],
            );
          }
        );
      }
    ).then((value) {
      return value ?? false; // Manejar el caso de cierre sin respuesta
    });

    if(resultPopUp){
      _reloadTableProducts(item.productsId!);
    };

  }

  // Mover a Ubicación CERO y QUITAR RELACIÓN
  Future<void> _popUpMoveZeroUnlink(context, ProductsLocationEntity item) async {
    TextEditingController quantityToMoveController = TextEditingController();
    quantityToMoveController.text = item.quantity.toString();
    SelectedLocation selectedLocation = SelectedLocation(0,
                                                          item.cajasId!,
                                                          item.productsId!,
                                                          item.locationsId!,
                                                          0);

    bool resultPopUp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return Consumer<ProductsLocationProvider>(
          builder: (context, provider, child) {

            return 
            AlertDialog(
              title: const Text('Mover a Ubicación CERO y QUITAR RELACIÓN'),
              content: SingleChildScrollView(
                child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                      _buildTextRow('', item.productsSku!, true),
                      _buildTextRow('', item.productsName!, false),
                      Divider(),
                      const SizedBox(height: 8,),
                      const Row(
                        children: [
                          Flexible(
                            flex:1,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Se eliminará la relación entre el producto y la ubicación actual además todo el stock quedará en ubicación CERO ",
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          )
                        ],
                       )
                     ]
                )
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'MOVER',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Cerrar");
                    }
                    provider.moveToZeroUnlink(selectedLocation);
            
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
                  child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                    return;
                  },
                ),
              ],
            );
          }
        );
      }
    ).then((value) {
      return value ?? false; // Manejar el caso de cierre sin respuesta
    });

    if(resultPopUp){
      _reloadTableProducts(item.productsId!);
    };
  }
  // Mover a Ubicación CERO y QUITAR RELACIÓN
  Future<void> _popUpMakeFavoriteLocation(context, ProductsLocationEntity item) async {
    TextEditingController noteController = TextEditingController();
    SelectedLocation selectedLocation = SelectedLocation(0,
                                                          item.cajasId!,
                                                          item.productsId!,
                                                          item.locationsId!,
                                                          0);

   bool resultPopUp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return Consumer<ProductsLocationProvider>(
          builder: (context, provider, child) {
            

            return AlertDialog(
              title: const Text('Convertir en ubicación favorita'),
              content: SingleChildScrollView(
                child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                      _buildTextRow('', item.productsSku!, true),
                      _buildTextRow('', item.productsName!, false),
                      Divider(),
                      const SizedBox(height: 8,),
                      Row(
                        children: [
                          Flexible(
                            flex:1,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                  label: Text("Comentario"),
                                  hintText: "Escribe aquí...", // Texto sugerido cuando está vacío
                                  border: OutlineInputBorder(), // Borde alrededor del TextField
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 10, // Permitir múltiples líneas sin límite
                                minLines: 5,   // Mostrar al menos 5 líneas de alto
                              ),
                            ),
                          )
                        ],
                       )
                     ]
                )
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Guardar");
                    }
                    provider.makeFavoriteLocation(selectedLocation, noteController.text);
            
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
                  child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                    return;
                  },
                ),
              ],
            );
          }
        );
      }
    ).then((value) {
      return value ?? false; // Manejar el caso de cierre sin respuesta
    });

    if(resultPopUp){
      _reloadTableProducts(item.productsId!);
    }
  }

  String _buildLocationString(LocationEntity location){
    String location_txt = "";
    if(location.P != ''){
      location_txt += "P${location.P}";
    }
    if(location.R != ''){
      location_txt += "-R${location.R}";
    }
    if(location.A != ''){
      location_txt += "-A${location.A}";
    }
    if(location.H != ''){
      location_txt += "-H${location.H}";
    }

    return location_txt;
  }
  
  Future<void> popUpLocationChange(BuildContext context, ProductsLocationEntity item, List<LocationEntity> locationOld) async {
    final productsLocationProvider = Provider.of<ProductsLocationProvider>(context, listen: false);
    int quantityUnLocated = item.quantity! - item.located!;
    final searchController = TextEditingController();
    final skuUbicacionController = TextEditingController();
    final quantityToMoveController = TextEditingController(text: quantityUnLocated.toString());
    TextEditingController optionSelected = TextEditingController();
    SelectedLocation selectedLocation = SelectedLocation(0,
                                                        item.cajasId!,
                                                        item.productsId!,
                                                        item.locationsId!,
                                                        int.parse(quantityToMoveController.text)
                                                      );
    bool showMenu = false;
    bool resultPopUp = false;
    int numElements = 0;
    
    String locationPastTxt = "";
    locationOld.forEach((element) {
    
      locationPastTxt += _buildLocationString(element) + "\t";

    });
    //List<String> stores = ["Principal", "secondario", "tercero", "cuarto"];

    resultPopUp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SearchLocationProvider>(
          builder: (context, provider, child) {
            // provider..addListener((){
            //   provider.showListResult = false;
            // });
            // provider.showListResult = false;
            // provider.notifyListeners();

            return AlertDialog(
              title: const Text('Cambiar de ubicación'),
              content: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextRow('', item.productsSku!, true),
                        _buildTextRow('', item.productsName!, false),
                         const SizedBox(height: 6),
                        _buildTextRow('', "Ubicaciones: \n(está o estuvo el producto)", false),
                        _buildTextRow('', locationPastTxt, false),
                         const SizedBox(height: 6),
                        _buildDropdownMenu(optionSelected, stores),
                        Row(
                         children: [
                           Flexible(
                             flex: 1,
                             child: Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: TextField(
                                 controller: searchController,
                                 decoration: InputDecoration(
                                   labelText: 'Buscar ubicación(destino):',
                                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
                                   suffixIcon: IconButton(
                                     icon: const Icon(Icons.clear),
                                     onPressed: () {
                                       searchController.clear(); // Limpiar el texto
                                       provider.results = [];
                                       provider.isLoading = false;
                                     },
                                   ),
                                   
                                 ),
                                 onChanged: (query){
                                   provider.searchLocation(query, item.cajasId!, item.productsId!);
                                   
                                 } 
                               ),
                             ),
                           ),
                           
                         ],
                       ),   
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: skuUbicacionController,
                          labelText: 'SKU ubicación:',
                          height: 30,
                          readOnly: true
                        ),
                        _buildTextField(
                          controller: quantityToMoveController,
                          labelText: 'Cantidad a mover:',
                          height: 50
                        ),
                      ],
                    ),
                  ),
                  provider.showListResult
                    ? Positioned(
                        bottom: -30, // Position the list at the bottom
                        left: 0,
                        right: 0,
                        //top:10,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: provider.results.map((option) {
                                  String locationTxt = _buildLocationString(option);
                                  //log("locationTxt: $locationTxt");
                                  numElements++;
                                  return Flexible(
                                    flex:1,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: ListTile(
                                            dense: true,
                                            //contentPadding: const EdgeInsets.only(top: 0, bottom: -10, left: 8.0, right: 8.0), 
                                            contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                                            title: Text("${option.locationsSku}: $locationTxt", style: TextStyle(fontSize: 12)),
                                            subtitle: Text("Descripción: ${option.description}"),
                                            onTap: () {
                                              //log("onTap ListTile: ${option.locationsSku}");
                                              searchController.text = locationTxt;
                                              skuUbicacionController.text = option.locationsSku!;
                                              
                                              provider.showListResult = false;
                                              provider.selectedLocationsId = option.locationsId;
                                              provider.selectedProductsId = item.productsId!;
                                              selectedLocation.locationsId = option.locationsId;
                                              selectedLocation.cajasId = option.cajasId;
                                              selectedLocation.quantity = int.parse(quantityToMoveController.text);
                                                                                                  
                                              provider.selectedLocationObj = selectedLocation;
                                                        
                                            },
                                          ),
                                        ),
                                        if (provider.results.length != numElements ) Divider(),
                                      ],
                                    ),
                                  );
                                  
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                          
                      )
                    : SizedBox(),  
                ]
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('MOVER', style: TextStyle(fontSize: 20.0)),
                  onPressed: () {
                    selectedLocation.cajasId = int.parse(optionSelected.text);
                    selectedLocation.quantity = int.parse(quantityToMoveController.text);
                    provider.selectedLocationObj = selectedLocation;
                    provider.notifyListeners();
                    log("optionSelected: ${SelectedLocation.toJson(selectedLocation)}");
                    productsLocationProvider.changeLocation(selectedLocation);
                    Navigator.pop(context, true);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      return value ?? false; // Manejar el caso de cierre sin respuesta
    });

    if(resultPopUp){
      _reloadTableProducts(item.productsId!);
    }
    
  }
  
  Widget _buildTextRow(String label, String value, bool bold) {
  return Row(
    children: [
      Flexible(
        flex: 1,
        child: Text("$label $value", style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ),
    ],
  );
}

  Widget _buildSearchField(TextEditingController controller, SearchLocationProvider provider, ProductsLocationEntity item) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: 'Buscar ubicación (destino):',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blue)
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clear();
          provider.results = [];
          provider.isLoading = false;
        },
      ),
    ),
    onChanged: (query) {
      provider.searchLocation(query, item.cajasId!, item.productsId!);
      if (provider.results.isNotEmpty) {
        //showMenu = true;
      }
    },
  );
}
  
  Widget _buildPopupMenu(SearchLocationProvider provider, TextEditingController searchController) {
    return Column(
      children: provider.results.map((location) {
        return ListTile(
          title: Text(location.txtLocation!), // Asume que tienes una propiedad txtLocation
          subtitle: Text("Descripción: ${location.description}"),
          onTap: () {
            // Acción al seleccionar un resultado
            print("Seleccionado: ${location.txtLocation}");
          },
        );
      }).toList(),
    );
  }

  Widget _buildDropdownMenu(TextEditingController optionSelected, List<StoreEntity> suggestions) {
    
   // log("Store: ${suggestions.length} - Store: ${stores.length}");

    return SizedBox(
      height: 60,
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: 'Selecciona una opción',
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue)
        ),
        ),
        items: suggestions.map((item) {
          return DropdownMenuItem<StoreEntity>(
            value: item,
            child: Text("${item.cajasId} ${item.cajasName.toString()}"),
          );
        }).toList(),
        onChanged: (StoreEntity? newValue){
          optionSelected.text = newValue!.cajasId.toString();
        }
      ),
    );
    
  }

  Widget _buildAutocompleteFieldOld(SearchLocationProvider provider, TextEditingController controller, TextEditingController textEditingController, int cajasId, int productsId) {
    return Autocomplete<LocationEntity>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<LocationEntity>.empty();
        }
        await provider.searchLocation(textEditingValue.text, cajasId, productsId);
        return provider.results;
      },
      displayStringForOption: (LocationEntity location) => location.txtLocation!,
      onSelected: (LocationEntity selection) {
        final locationTxt = _buildLocationString(selection);
        controller.text = locationTxt;
        provider.selectedLocation = locationTxt;
      },
      fieldViewBuilder: (BuildContext context, textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Buscar ubicación',
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<LocationEntity> onSelected, Iterable<LocationEntity> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 100,
              child: SingleChildScrollView(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final location = options.elementAt(index);
                    final locationTxt = _buildLocationString(location);
                    return ListTile(
                      title: Text(locationTxt),
                      subtitle: Text("Descripción: ${location.description}"),
                      onTap: () {
                        textEditingController.text = locationTxt;
                        onSelected(location);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAutocompleteField(SearchLocationProvider provider, TextEditingController controller, TextEditingController textEditingController, int cajasId, int productsId) {
    return Autocomplete<LocationEntity>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        log("textEditingValue: ${textEditingValue.text}");
        // if(textEditingValue.text.isEmpty){
        //   return const Iterable<Location>.empty();
        // }
        //await provider.searchLocation(textEditingValue.text, cajasId, productsId);
        List<LocationEntity> locFinded = provider.results;/*.where((location) => 
              location.txtLocation.toLowerCase().contains(textEditingValue.text.toLowerCase())
            ).toList();*/
        log("locFinded: $locFinded");
        return locFinded;/*.where((location) => 
              location.txtLocation.toLowerCase().contains(textEditingValue.text.toLowerCase())
            ).toList();*/
      },
      displayStringForOption: (LocationEntity location) => location.txtLocation!,
      onSelected: (value) => print(value.txtLocation),
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Buscar ubicación',
            border: OutlineInputBorder(),
          ),
          onChanged:(value) async{
            await provider.searchLocation(textEditingController.text, cajasId, productsId);
          },
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<LocationEntity> onSelected, Iterable<LocationEntity> options) {

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              //height: 100,
              child: SingleChildScrollView(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final location = options.elementAt(index);
                    final locationTxt = _buildLocationString(location);
                    return ListTile(
                      title: Text(locationTxt),
                      subtitle: Text("Descripción: ${location.description}"),
                      onTap: () {
                        textEditingController.text = locationTxt;
                        onSelected(location);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required double height,
    bool readOnly = false
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SizedBox(
        height: height,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                controller.clear(); // Limpiar el texto
              },
            )
          ),
          onChanged: (value) async {
            if(value.isNotEmpty){
               controller.text = value;
            }
          },
        ),
      ),
    );
  }


}