import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:provider/provider.dart';

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
    List<String> stores = ["Principal", "secondario", "tercero", "cuarto"];

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
                        _buildDropdownMenu(optionSelected, stores.cast<StoreEntity>()),
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
  
  void _reloadTableProducts(int i) {
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

 /* Widget _buildAutocompleteFieldOld(SearchLocationProvider provider, TextEditingController controller, TextEditingController textEditingController, int cajasId, int productsId) {
    return Autocomplete<Location>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Location>.empty();
        }
        await provider.searchLocation(textEditingValue.text, cajasId, productsId);
        return provider.results;
      },
      displayStringForOption: (Location location) => location.txtLocation!,
      onSelected: (Location selection) {
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
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Location> onSelected, Iterable<Location> options) {
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
  }*/
  
  /*Widget _buildAutocompleteField(SearchLocationProvider provider, TextEditingController controller, TextEditingController textEditingController, int cajasId, int productsId) {
    return Autocomplete<Location>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        log("textEditingValue: ${textEditingValue.text}");
        // if(textEditingValue.text.isEmpty){
        //   return const Iterable<Location>.empty();
        // }
        //await provider.searchLocation(textEditingValue.text, cajasId, productsId);
        List<Location> locFinded = provider.results;/*.where((location) => 
              location.txtLocation.toLowerCase().contains(textEditingValue.text.toLowerCase())
            ).toList();*/
        log("locFinded: $locFinded");
        return locFinded;/*.where((location) => 
              location.txtLocation.toLowerCase().contains(textEditingValue.text.toLowerCase())
            ).toList();*/
      },
      displayStringForOption: (Location location) => location.txtLocation!,
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
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Location> onSelected, Iterable<Location> options) {

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
  }*/

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

