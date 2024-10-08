import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/product_locations_model.dart';
import 'package:piking/domain/provider/products_location_provider.dart';
import 'package:piking/presentation/shared/swipe_detector.dart';
import 'package:piking/presentation/stock/maximum_quantity_page.dart';
import 'package:provider/provider.dart';

class LocationMovePage extends StatefulWidget {
  LocationMovePage({super.key, required this.quantity});
  int quantity = 0;
  @override
  State<LocationMovePage> createState() => _LocationMoveState();
}

class _LocationMoveState extends State<LocationMovePage> {
  List<ProductsLocation> productsLocationsList = [];
  late List<ProductsLocation> totaProductsLocation = [];
  TextEditingController newLocationController = TextEditingController();
  int quantityToMove = 0;
  @override
  void initState(){
    super.initState();
    quantityToMove = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stockLocations = [];
    final productsLocationProvider = Provider.of<ProductsLocationProviderOld>(context, listen: false);
    totaProductsLocation = productsLocationProvider.productsLocationsList;
    log("productsLocationsList: $productsLocationsList");
    if (totaProductsLocation.isNotEmpty) {
      double sinUbicar = 0;
      Iterable<ProductsLocation> sinUbicarElements = totaProductsLocation.where((item) => item.productsQuantity - item.located > 0);
      Iterable<ProductsLocation> locatedElements = totaProductsLocation.where((item) => item.located > 0);
      if (sinUbicarElements != null) {
        for (ProductsLocation item in sinUbicarElements) {
          sinUbicar += item.productsQuantity - item.quantity;
        }
      }
      
      for (ProductsLocation item in totaProductsLocation) {
        log("productsQuantity: ${item.productsQuantity} - quantity: ${item.quantity}");
        log("item: ${item.locationsId}");
        sinUbicar += item.productsQuantity - item.located;

        if (item.quantity > 0) {
          stockLocations.add(GestureDetector(
            onTap: () {
              print('Clic en Card');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MaximumQuantityPage(from: "", quantity: item.quantity, productsLocation: item)),
              );
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
                          Text("SKU: ${item.productsSku}"),
                          Text("Ref: ${item.reference}"),
                        ],
                      ),
                      Row(
                        children: [
                          Text(" ${item.productsName}"),
                        ],
                      ),
                      Row(
                        children: [
                          Text("${item.location} => "),
                          Text("${item.quantity}"),
                        ],
                      ),
                    ],
                  ),
                )),
          ));
        }
      }
      stockLocations.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: newLocationController,
                          decoration: InputDecoration(
                            labelText: 'Nueva Localización',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.blue)),
                          ),
                          onChanged: (value) async {
                            log(value);
                            productsLocationProvider.validateEan(value);
                          },
                        ),
                      ),
                    )
                  ],
                )
      );
      if(locatedElements.isNotEmpty){
        for (ProductsLocation item in locatedElements){
          stockLocations.add(GestureDetector(
          onTap: () {
            print('Clic en Card');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MaximumQuantityPage(
                        from: "",
                        quantity: quantityToMove,
                        productsLocation: item,
                      )),
            );
          },
          child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("${item.location}"),
                    item.quantityMax > 0 ? Text(" (max ${item.quantityMax} ud)") : const Text(""),
                  ],
                ),
              )),
        ));
        }
      }
      //for (ProductsLocation item in sinUbicarElements) {
      /*if (totaProductsLocation[0].quantity > 0) {
        stockLocations.add(GestureDetector(
          onTap: () {
            print('Clic en Card');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MaximumQuantityPage(
                        from: "",
                        quantity: sinUbicar.toInt(),
                        productsLocation: ProductsLocation.empty(),
                      )),
            );
          },
          child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Sin ubicar => "),
                    Text("${totaProductsLocation[0].productsQuantity - totaProductsLocation[0].located}"),
                    Text(" (max ${totaProductsLocation[0].quantityMax} ud)"),
                  ],
                ),
              )),
        ));
      }*/
      //}
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Mover a ubicación"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
              child: SwipeDetector(
                  onSwipeLeft: () {
                    log("Vamos a la izquerda");
                  },
                  onSwipeRight: () {
                    log("vamos a la derecha ");
                  },
                  child: Column(children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                            //
                            children: stockLocations),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          iconSize: 40.0,
                          color: Color.fromARGB(255, 23, 144, 243),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 40.0,
                          color: const Color.fromARGB(255, 23, 144, 243),
                          onPressed: () {
                            //pageController.nextPage(duration: Durations.medium1, curve: Curves.bounceIn);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MaximumQuantityPage(
                                        from: "",
                                        quantity: 0,
                                        productsLocation: ProductsLocation.empty(),
                                      )),
                            );
                          },
                        ),
                      )
                    ]),
                  ]))),
        ));
  }
}
