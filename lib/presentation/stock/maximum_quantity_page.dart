import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:piking/domain/model/product_locations_model.dart';
import 'package:piking/domain/provider/products_location_provider.dart';
import 'package:piking/presentation/shared/swipe_detector.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MaximumQuantityPage extends StatefulWidget {
  MaximumQuantityPage({super.key, required this.from, required this.quantity, required this.productsLocation});
  late ProductsLocation productsLocation;
  late String from;
  late int quantity;
  @override
  State<MaximumQuantityPage> createState() => _MaximumQuantityPageState();
}

class _MaximumQuantityPageState extends State<MaximumQuantityPage> {
  ProductsLocation productsLocation = ProductsLocation.empty();
  int quantity = 0;
  List<ProductsLocation> productsLocationsList = [];
  late List<ProductsLocation> totaProductsLocation = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productsLocation = widget.productsLocation;
    quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stockLocations = [];
    final productsLocationProvider = Provider.of<ProductsLocationProviderOld>(context, listen: false);
    totaProductsLocation = productsLocationProvider.productsLocationsList;
    log("productsLocationsList: $productsLocationsList");

    stockLocations.add(Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("En la ${productsLocation.location} que vas a UBICAR el Producto\n ${productsLocation.productsName},\n la CANTIDAD $quantity")
                            ],
                          ),
                        ));
    if(totaProductsLocation.isNotEmpty){
      for (ProductsLocation item in totaProductsLocation){
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
                        children: [
                          Text("${item.location} => "),
                          Text("${item.located}"),
                        ],
                      ),
                    ],
                  ),
                )),
          ));
      }
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Cantidad maxima"),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: stockLocations,
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => LocationMovePage()),
                          // );
                        },
                      ),
                    )
                  ])
                ]),
              ),
            ),
          ),
        ));
  }
}
