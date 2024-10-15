import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/feature/stock/presentation/actions/shared.dart';
import 'package:piking/vars.dart';
import 'package:provider/provider.dart';

class RemoveStock extends StatefulWidget {
  RemoveStock({super.key, required this.item, required this.locationOld, required this.items});
  ProductsLocationEntity item; 
  List<LocationEntity> locationOld;
  List<ProductsLocationEntity> items;

  @override
  State<RemoveStock> createState() => _RemoveStockState();
}

class _RemoveStockState extends State<RemoveStock> {
  late ProductsLocationEntity item; 
  List<LocationEntity> locationOld = [];
  List<ProductsLocationEntity> items = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController skuUbicacionController = TextEditingController();
  TextEditingController quantityToMoveController = TextEditingController();
  FocusNode textFieldFocusNode1 = FocusNode();
  GlobalKey textFieldKey = GlobalKey();
  // Posición del TextField
  double? topPosition;
  double? leftPosition;

  @override
  initState() {
    super.initState();
    item = widget.item;
    locationOld = widget.locationOld;
    items = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTextFieldPosition();
      //FocusScope.of(context).requestFocus(textFieldFocusNode1);
    });
  }
  @override
  void dispose(){
    searchController.dispose();
    skuUbicacionController.dispose();
    quantityToMoveController.dispose();
    textFieldFocusNode1.dispose();
    super.dispose();
  }
   // Función para obtener la posición del TextField en la pantalla
  void _getTextFieldPosition() {
    final RenderBox renderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    if(mounted){
      setState(() {
        topPosition = offset.dy + renderBox.size.height -60; // Justo debajo del TextField
        leftPosition = offset.dx; // Alinear con el borde izquierdo del TextField
      });
    }
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
    
    final provider = Provider.of<SearchLocationProvider>(context, listen: false);

    quantityToMoveController.text = item.quantity.toString();

    List<Widget> locationButtons = [];

    String locationPastTxt = "";

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
              SelectedLocation selectedLocation = SelectedLocation(
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

    int numElements = 0;
   
   // FocusScope.of(context).requestFocus(textFieldFocusNode1);
    
    //FocusScope.of(context).requestFocus(textFieldFocusNode1);
    textFieldFocusNode1.requestFocus();
    //Consumer<SearchLocationProvider>
    
    return Consumer<SearchLocationProvider>(
      builder: (context, provider, child) {
            return Container(
              width: MediaQuery.of(context).size.width, // Fullscreen width
              height: MediaQuery.of(context).size.height, // Fullscreen height
              color: Colors.white, // Color de fondo
              padding: const EdgeInsets.all(16.0),
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
                            child: FocusScope(
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
                                  Row(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: TextField(
                                            key: textFieldKey,
                                            focusNode: textFieldFocusNode1,
                                            showCursor: true,
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
                                              // Si hay solo un resultado, selecciona automáticamente
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
                                                setState(() {
                                                  //FocusScope.of(context).requestFocus(textFieldFocusNode1);
                                                });
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
                                        log("Length: ${ provider.results.length}");
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
                            provider.moveToLocation(int.parse(quantityToMoveController.text));
                            FocusScope.of(context).unfocus();
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
                            provider.notifyListeners();
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context, true);
                            return;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
      });

  }
   _locationPressed(int locationsId){
    log("LocationsId: $locationsId");

  }
  _check_length_elem(SearchLocationProvider provider, TextEditingController searchController, List<LocationEntity> option){
    log("Inside 1 option");
    if(option.length == 1){

      String locationTxt = SharedFunc.buildLocationString(option.first);
      searchController.text = locationTxt;
      provider.results = [];
      provider.isLoading = false;
      provider.showListResult = false;
      provider.selectedLocationsId = option.first.locationsId;
      provider.selectedProductsId = item.productsId!;
      provider.notifyListeners();
      SelectedLocation selectedLocation = SelectedLocation(
                  option.first.locationsId,
                  option.first.cajasId,
                  item.productsId!,
                  item.locationsId!,
                  int.parse(quantityToMoveController.text),
                );
      provider.selectedLocationObj = selectedLocation;
      
    }
  }
  

}