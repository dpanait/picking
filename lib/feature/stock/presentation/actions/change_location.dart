import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:piking/feature/stock/domain/repository/store_repository.dart';
import 'package:piking/feature/stock/presentation/actions/shared.dart';
import 'package:piking/injection_container.dart';
import 'package:provider/provider.dart';

class ChangeLocation extends StatefulWidget {
  ChangeLocation({super.key, required this.item, required this.locationOld, required this.items});
  ProductsLocationEntity item; 
  List<LocationEntity> locationOld;
  List<ProductsLocationEntity> items;
  @override
  State<ChangeLocation> createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {

  late ProductsLocationEntity item; 
  List<LocationEntity> locationOld = [];
  List<ProductsLocationEntity> items = [];
  List<StoreEntity> stores = [];
  StoreEntity selectedStore = StoreEntity.empty();
  TextEditingController optionSelected = TextEditingController();
  GlobalKey textFieldKey = GlobalKey();
  final searchController = TextEditingController();
  final skuUbicacionController = TextEditingController();
  final quantityToMoveController = TextEditingController();
  // Posición del TextField
  double? topPosition;
  double? leftPosition;

  var storeRepository = di.get<StoreRepository>();
  
  @override
  initState() {
    super.initState();
    item = widget.item;
    locationOld = widget.locationOld;
    items = widget.items;
    _loadStores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTextFieldPosition();
    });
  }
  @override
  void dispose(){
    searchController.dispose();
    skuUbicacionController.dispose();
    quantityToMoveController.dispose();
    super.dispose();
  }

  _loadStores() async {
    List<StoreEntity> storesFunc = await storeRepository.getStore();
    if(mounted){
      setState(() {
        stores = storesFunc;
        selectedStore = storesFunc.firstWhere((obj) => obj.cajasId == widget.item.cajasId);
        optionSelected.text = selectedStore.cajasId.toString();
      });
    }
   
  }
  // Función para obtener la posición del TextField en la pantalla
  void _getTextFieldPosition() {
    final RenderBox renderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    setState(() {
      topPosition = offset.dy + renderBox.size.height -60; // Justo debajo del TextField
      leftPosition = offset.dx; // Alinear con el borde izquierdo del TextField
    });
  }

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        //appBar: CustomAppBar(icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: PickingVars.IDCLIENTE, title: "Move", onActionPressed: () {}),
      resizeToAvoidBottomInset: true,
      body: Center(child: _startPage(context)),
    );
  }

  Widget _startPage(BuildContext context) {
    final productsLocationProvider = Provider.of<ProductsLocationProvider>(context, listen: false);
    final provider = Provider.of<SearchLocationProvider>(context, listen: false);
    int quantityUnLocated = item.quantity! - item.located!;
    quantityToMoveController.text = quantityUnLocated.toString();
    
    SelectedLocation selectedLocation = SelectedLocation(
      0,
      item.cajasId!,
      item.productsId!,
      item.locationsId!,
      int.parse(quantityToMoveController.text)
    );
    //StoreEntity slectedStore = stores.first;
    int numElements = 0;
    List<Widget> locationButtons = [];

    for (var element in items) {

      LocationEntity location = locationOld.firstWhere((obj) => obj.locationsId == element.locationsId);

      locationButtons.add( Padding(
        padding: const EdgeInsets.all(0.0),
        child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)), // Controla el padding interno
            minimumSize: MaterialStateProperty.all<Size>(Size(0, 30)), // Controla el tamaño mínimo del botón
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce el tamaño del área de toque
          ),
            onPressed: (){
              searchController.text = SharedFunc.buildLocationString(location);
              quantityToMoveController.text = (element.quantity!).toString();
              selectedLocation = SelectedLocation(
                element.locationsId!,
                element.cajasId!,
                element.productsId!,
                item.locationsId!,
                int.parse(quantityToMoveController.text),
              );
              //log("Selected: ${SelectedLocation.toJson(selectedLocation)}");
              provider.selectedLocationObj = selectedLocation;
        
            }, 
            child: Text(SharedFunc.buildLocationString(location), style: TextStyle(color: Colors.blueAccent),)
          ),
      )
      );
    }
    //List<String> stores = ["Principal", "secondario", "tercero", "cuarto"];

    return Consumer<SearchLocationProvider>(
      builder: (context, provider, child) {
        return Card(
              // width: MediaQuery.of(context).size.width, // Fullscreen width
              // height: MediaQuery.of(context).size.height, // Fullscreen height
              // color: Colors.white, // Color de fondo
              // padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text("Mover", style: TextStyle(fontWeight: FontWeight.bold,),)
                    ],),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SharedFunc.buildTextRow('', item.productsSku!, true),
                                SharedFunc.buildTextRow('', item.productsName!, false),
                                const SizedBox(height: 10),
                                SharedFunc.buildTextRow('', 'Ubicaciónes: (está o estuvo el producto)', false),
                                //_buildTextButtonRow('', locationPastTxt, locationButtons, false),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Wrap(
                                        spacing: 8.0, // Espacio entre los botones
                                        runSpacing: -2.0, // Espacio entre las filas
                                        children: locationButtons
                            
                                      )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SharedFunc.buildDropdownMenu(optionSelected, stores, selectedStore),
                                const SizedBox(height: 10.0,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: TextField(
                                          key: textFieldKey,
                                          autofocus: true,
                                          controller: searchController,
                                          decoration: InputDecoration(
                                            labelText: 'Buscar ubicación(destino):',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(color: Colors.blue),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                searchController.clear(); // Limpiar el texto
                                                provider.results = [];
                                                provider.isLoading = false;
                                                provider.showListResult = false;
                                              },
                                            ),
                                          ),
                                          onChanged: (query) async{
                                            await provider.searchLocation(query, item.cajasId!, item.productsId!);
                                            if (provider.results.length == 1) {
                                              //log("Solo una opcion");
                                              // Asigna el texto del TextField y selecciona la ubicación
                                              searchController.text = SharedFunc.buildLocationString(provider.results[0]);
                                              provider.selectedLocationsId = provider.results[0].locationsId; // Asegúrate de actualizar el ID
                                              provider.selectedProductsId = item.productsId!; // También actualiza el ID del producto

                                              // Crea el objeto SelectedLocation y actualiza el provider
                                              SelectedLocation selectedLocation = SelectedLocation(
                                                provider.results[0].locationsId,
                                                provider.results[0].cajasId,
                                                item.productsId!,
                                                item.locationsId!,
                                                int.parse(quantityToMoveController.text),
                                              );
                                              provider.selectedLocationObj = selectedLocation;

                                              // Oculta la lista de resultados
                                              provider.showListResult = false;
                                              FocusScope.of(context).unfocus(); 
                                            }
                                          },
                                          onTap: (){
                                            //FocusScope.of(context).requestFocus(_focusTextFieldSearchNode);
                                          }
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SharedFunc.buildDropdownMenuQuantity(quantityToMoveController, int.parse(quantityToMoveController.text)),
                                // SharedFunc.buildTextField(
                                //   context: context,
                                //   controller: quantityToMoveController,
                                //   labelText: 'Cantidad a mover:',
                                //   height: 60,
                                // ),
                              ],
                            ),
                          ),
                        ),
                        if (provider.showListResult && provider.results.length > 1)
                          Positioned(
                            //bottom: -30, // Position the list at the bottom
                            top: topPosition, // Usamos la posición calculada para moverlo
                            left: leftPosition,
                            //right: 0,
                            child: Material(
                              elevation: 4.0,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: provider.results.map((option) {
                                        String locationTxt = SharedFunc.buildLocationString(option);
                                        return Flexible(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                child: ListTile(
                                                  dense: true,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                                                  title: Text(
                                                    "${option.locationsSku}: $locationTxt",
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                  subtitle: Text("Descripción: ${option.description}"),
                                                  onTap: () {
                                                    // log("quantityToMoveController.text: ${quantityToMoveController.text}");
                                                    // log("item: ${item.locationsId}");
                                                    searchController.text = locationTxt;
                                                    skuUbicacionController.text = option.locationsSku!;
                                                    provider.showListResult = false;
                                                    provider.selectedLocationsId = option.locationsId;
                                                    provider.selectedProductsId = item.productsId!;
                                                    SelectedLocation selectedLocation = SelectedLocation(
                                                      option.locationsId,
                                                      option.cajasId,
                                                      item.productsId!,
                                                      item.locationsId!,
                                                      int.parse(quantityToMoveController.text),
                                                    );
                                                    provider.selectedLocationObj = selectedLocation;
                                                  },
                                                ),
                                              ),
                                              if (provider.results.length != numElements) Divider(),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('MOVER', style: TextStyle(fontSize: 20.0)),
                          onPressed: () async {
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
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CERRAR', style: TextStyle(fontSize: 20.0)),
                          onPressed: () async {
                            provider.showListResult = false;
                            provider.notifyListeners();
                            Navigator.pop(context, false);
                            return;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

      },
    );
     
  }
}

/*return Container(
          width: MediaQuery.of(context).size.width, // Fullscreen width
          height: MediaQuery.of(context).size.height, // Fullscreen height
          color: Colors.white, // Color de fondo
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(children:  [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text("Cambiar de ubicación", style: TextStyle(fontWeight: FontWeight.bold,),)
                  ],),
                ),
              ],
              ),
              Stack(
                children: [
                  
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SharedFunc.buildTextRow('', item.productsSku!, true),
                      SharedFunc.buildTextRow('', item.productsName!, false),
                      const SizedBox(height: 16),
                      SharedFunc.buildTextRow('', "Ubicaciones: \n(está o estuvo el producto)", false),
                      //SharedFunc.buildTextRow('', locationPastTxt, false),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Wrap(
                              spacing: 8.0, // Espacio entre los botones
                              runSpacing: 0.0, // Espacio entre las filas
                              children: locationButtons
                            ),
                          ) 
                        ],
                      ),
                      const SizedBox(height: 16),
                      //SharedFunc.buildDropdownMenu(optionSelected, stores, selectedStore),
                      //SharedFunc.dropDownButton(optionSelected, stores, selectedStore),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextField(
                                key: textFieldKey,
                                autofocus: true,
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
                                      provider.showListResult = false;
                                    },
                                  ),
                                  
                                ),
                                onChanged: (query){
                                  provider.searchLocation(query, item.cajasId!, item.productsId!);
                                  //_getTextFieldPosition();
                                  
                                } 
                              ),
                            ),
                          ),
                          
                        ],
                      ),   
                      const SizedBox(height: 16),
                      SharedFunc.buildTextField(
                        context: context,
                        controller: quantityToMoveController,
                        labelText: 'Cantidad a mover:',
                        height: 60
                      ),
                      
                      
                    ],
                  ),
                  provider.showListResult
                    ? Positioned(
                        //bottom: -30, // Position the list at the bottom
                        top: topPosition, // Usamos la posición calculada para moverlo
                        left: leftPosition,
                        //right: 0,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: provider.results.map((option) {
                                    String locationTxt = SharedFunc.buildLocationString(option);
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
                        ),
                          
                      )
                    : SizedBox(),  
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        provider.showListResult = false;
                        provider.notifyListeners();
                        Navigator.pop(context, false);
                      },
                    ),
                  ]
                ),
              )
            
            ],
          ),
          
        );*/