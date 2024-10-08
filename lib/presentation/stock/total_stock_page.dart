import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/model/product_locations_model.dart';
import 'package:piking/domain/provider/products_location_provider.dart';
import 'package:piking/presentation/shared/swipe_detector.dart';
import 'package:piking/presentation/stock/quantity_move_page.dart';
import 'package:provider/provider.dart';

class TotalStockPage extends StatefulWidget {
  TotalStockPage({super.key, required this.totaProductsLocation});

  late List<ProductsLocation> totaProductsLocation;

  @override
  State<TotalStockPage> createState() => _TotalStockPageState();
}

class _TotalStockPageState extends State<TotalStockPage> {
  late List<ProductsLocation> totaProductsLocation = [];
  @override
  initState() {
    super.initState();
    totaProductsLocation = widget.totaProductsLocation;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stockLocations = [];
    final productsLocationProvider = Provider.of<ProductsLocationProviderOld>(context, listen: false);
    log("productsLocationProvider: ${productsLocationProvider.productsLocationsList.length}");
    if (productsLocationProvider.productsLocationsList.isNotEmpty) {
      totaProductsLocation = productsLocationProvider.productsLocationsList;
    }

    if (totaProductsLocation.isNotEmpty) {
      double sinUbicar = 0;
      double quantityLocated = 0;

      Iterable<ProductsLocation> sinUbicarElements = totaProductsLocation.where((item) => item.productsQuantity - item.located > 0);
      Iterable<ProductsLocation> locatedElements = totaProductsLocation.where((item) => item.located > 0);
      for (ProductsLocation item in sinUbicarElements) {
        sinUbicar += item.productsQuantity - item.quantity;
      }
          for (ProductsLocation item in locatedElements){
        quantityLocated += item.located;
      }
          for (ProductsLocation item in totaProductsLocation) {
        log("productsQuantity: ${item.productsQuantity} - quantity: ${item.quantity}");
        sinUbicar += item.productsQuantity - item.located;

        if (item.quantity > 0) {
          stockLocations.add(GestureDetector(
            onTap: () {
              print('Clic en Card');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuantityMovePage(from: "", quantity: item.quantity, productsLocation: item)),
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
      //for (ProductsLocation item in sinUbicarElements) {
      if (totaProductsLocation[0].quantity - totaProductsLocation[0].located > 0) {
        stockLocations.add(GestureDetector(
          onTap: () {
            print('Clic en Card');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuantityMovePage(
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
      }
      if (totaProductsLocation[0].located > 0) {
        stockLocations.add(GestureDetector(
          onTap: () {
            print('Clic en Card');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuantityMovePage(
                        from: "",
                        quantity: quantityLocated.toInt(),
                        productsLocation: locatedElements.first,
                      )),
            );
          },
          child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("${totaProductsLocation[0].location} => "),
                    Text("${totaProductsLocation[0].located}"),
                    totaProductsLocation[0].quantityMax > 0 ? Text(" (max ${totaProductsLocation[0].quantityMax} ud)") : const Text(""),
                  ],
                ),
              )),
        ));
      }
      //}
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Cantidad total"),
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
              child: Center(
                  child: Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                      //
                      children: stockLocations),
                )),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 40.0,
                      color: const Color.fromARGB(255, 23, 144, 243),
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
                          MaterialPageRoute(builder: (context) => QuantityMovePage(from: "", quantity: 0, productsLocation: ProductsLocation.empty())),
                        );
                      },
                    ),
                  )
                ]),
              ])),
            ),
          ),
        ));
  }
}
