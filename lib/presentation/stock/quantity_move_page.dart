import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:piking/domain/model/product_locations_model.dart';
import 'package:piking/presentation/shared/swipe_detector.dart';
import 'package:piking/presentation/stock/location_move_page.dart';

// ignore: must_be_immutable
class QuantityMovePage extends StatefulWidget {
  QuantityMovePage({super.key, required this.from, required this.quantity, required this.productsLocation});
  late String from;
  late int quantity;
  late ProductsLocation productsLocation;

  @override
  State<QuantityMovePage> createState() => _QuantityMovePageState();
}

class _QuantityMovePageState extends State<QuantityMovePage> {
  TextEditingController moveQuantityController = TextEditingController();
  ProductsLocation productsLocation = ProductsLocation.empty();
  @override
  void initState() {
    super.initState();
    moveQuantityController.text = widget.quantity.toString();
    productsLocation = widget.productsLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Cantidad para mover"),
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
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [Text("Cantidad para mover")],
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: moveQuantityController,
                            decoration: InputDecoration(
                              labelText: 'Ud',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.blue)),
                            ),
                          ),
                        ),
                      ]),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              const Text("Ud:                         "),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      int quantity = int.parse(moveQuantityController.text) + 1;
                                      if(quantity <= widget.quantity){
                                        moveQuantityController.text = quantity.toString();
                                      }
                                      
                                    });
                                  }, //
                                  icon: const Icon(Icons.add, color: Colors.green)),
                              IconButton(
                                  onPressed: () {
                                    int quantity = int.parse(moveQuantityController.text) - 1;
                                    if (quantity >= 0) {
                                      setState(() {
                                        moveQuantityController.text = quantity.toString();
                                      });
                                    }
                                  }, //
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.red,
                                  ))
                            ]),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              Text("Paquetes (${productsLocation.udsPack} ud)"),
                              IconButton(
                                  onPressed: () {
                                    int quantity = int.parse(moveQuantityController.text) + productsLocation.udsPack;
                                    if(quantity <= widget.quantity){
                                      setState(() {
                                        moveQuantityController.text = quantity.toString();
                                      });
                                    }
                                  }, //
                                  icon: const Icon(Icons.add, color: Colors.green)),
                              IconButton(
                                  onPressed: () {
                                    int quantity = int.parse(moveQuantityController.text) - productsLocation.udsPack;
                                    if (quantity >= 0) {
                                      setState(() {
                                        moveQuantityController.text = quantity.toString();
                                      });
                                    }
                                  }, //
                                  icon: const Icon(Icons.remove, color: Colors.red))
                            ]),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              Text("Cajas (${productsLocation.udsBox} ud)    "),
                              IconButton(
                                  onPressed: () {
                                    int quantity = int.parse(moveQuantityController.text) + productsLocation.udsBox;
                                    if(quantity <= widget.quantity){
                                      setState(() {
                                        moveQuantityController.text = quantity.toString();
                                      });
                                    }
                                  }, //
                                  icon: const Icon(Icons.add, color: Colors.green)),
                              IconButton(
                                  onPressed: () {
                                    int quantity = int.parse(moveQuantityController.text) - productsLocation.udsBox;
                                    if (quantity >= 0) {
                                      setState(() {
                                        moveQuantityController.text = quantity.toString();
                                      });
                                    }
                                  }, //
                                  icon: const Icon(Icons.remove, color: Colors.red))
                            ]),
                          ],
                        ),
                      )
                    ]),
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
                            MaterialPageRoute(builder: (context) => LocationMovePage(quantity: int.parse(moveQuantityController.text),)),
                          );
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
