import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/domain/entities/store_entity.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';

class SharedFunc{
  static String buildLocationString(LocationEntity location){
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
  static Widget buildTextRow(String label, String value, bool bold) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Text("$label $value", style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
    );
  }
  static Widget buildTextButtonRow(
    String label,
    String value,
    List<Widget> listButton,
    bool bold
  ){
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Column(
            children: listButton

          )),
      ],
    );
  }


  static Widget buildSearchField(TextEditingController controller, SearchLocationProvider provider, ProductsLocationEntity item) {
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
  
  static Widget buildPopupMenu(SearchLocationProvider provider, TextEditingController searchController) {
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

  static Widget buildDropdownMenu(TextEditingController optionSelected, List<StoreEntity> suggestions, StoreEntity selectedStore) {
    
   // log("Store: ${suggestions.length} - Store: ${stores.length}");
   //log("SelectedStore: ${selectedStore.props}");

    return SizedBox(
      height: 60,
      child: DropdownButtonFormField(
        value: selectedStore,
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
  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required double height,
    bool readOnly = false
  }) {
    return Padding(
      padding: const EdgeInsets.all(0),
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
                 controller.text = '0';
              },
            )
          ),
          onTap: (){
          },
          onChanged: (value) async {
            if(value.isNotEmpty){
               controller.text = value;
            } else {
              controller.text = '0';
            }
          },
        ),
      ),
    );
  }
  static Widget dropDownButton(TextEditingController optionSelected, List<StoreEntity> suggestions, StoreEntity selectedStore){
    return PopupMenuButton<StoreEntity>(
        onSelected: (StoreEntity result) {
          
            optionSelected.text = result.cajasId.toString();
          
        },
         itemBuilder: (BuildContext context) => suggestions.map<PopupMenuEntry<StoreEntity>>((StoreEntity item){
          return PopupMenuItem<StoreEntity>(
            value: item,
            child: Text("${item.cajasId} ${item.cajasName.toString()}"),
          );
         }).toList()
         //<PopupMenuEntry<StoreEntity>>[
        //   const PopupMenuItem<StoreEntity>(
        //     value: 'Opción 1',
        //     child: Text('Opción 1'),
        //   ),
        //   const PopupMenuItem<StoreEntity>(
        //     value: 'Opción 2',
        //     child: Text('Opción 2'),
        //   ),
        // ],
      );
  //   return DropdownButton<StoreEntity>(
  //     value: selectedStore,
  //     onChanged: (StoreEntity? newValue) {
        
  //       optionSelected.text = newValue!.cajasId.toString();
        
  //     },
  //     items: suggestions
  //         .map<DropdownMenuItem<StoreEntity>>((StoreEntity item) {
  //       return DropdownMenuItem<StoreEntity>(
  //         value: item,
  //         child: Text("${item.cajasId} ${item.cajasName.toString()}"),
  //       );
  //     }).toList(),
  //   );
  }
  static Widget buildDropdownMenuQuantity(TextEditingController optionSelected, int maxNumber) {
    
   // log("Store: ${suggestions.length} - Store: ${stores.length}");
   //log("SelectedStore: ${selectedStore.props}");
     List<int> numbers = List<int>.generate(maxNumber + 1, (index) => index);

    return SizedBox(
      height: 60,
      child: DropdownButtonFormField(
        value: maxNumber,
        decoration: InputDecoration(
          labelText: 'Selecciona una opción',
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue)
        ),
        ),
        items: numbers.map((item) {
          return DropdownMenuItem<int>(
            value: item,
            child: Text("$item"),
          );
        }).toList(),
        onChanged: (int? newValue){
          optionSelected.text = newValue.toString();
        }
      ),
    );
    
  }

}