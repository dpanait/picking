import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/inventory.dart';
import 'package:piking/presentation/inventory_details_page.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/vars.dart';

class LocationProductsList extends StatefulWidget {
  final List<Inventory> products;
  const LocationProductsList({super.key, required this.products});

  @override
  State<LocationProductsList> createState() => _LocationProductsList();
}

class _LocationProductsList extends State<LocationProductsList> {
  int? selectedProductIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            icon: null, trailingIcon: null, onPressIconButton: () {}, idcliente: PickingVars.IDCLIENTE, title: "Multi localizaciones", onActionPressed: () {}),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(children: [
                  Expanded(
                      child: ListView.separated(
                          itemCount: widget.products.length,
                          separatorBuilder: (context, index) => const Divider(
                                color: Colors.grey,
                                height: 1,
                                thickness: 1,
                              ),
                          itemBuilder: (context, index) {
                            Inventory product = widget.products[index];
                            if (kDebugMode) {
                              print(jsonEncode(product));
                            }
                            final isSelected = selectedProductIndex == index;

                            return InkWell(
                              onTap: () {
                                if (PickingVars.CAJASID == 0) {
                                  const snackBar = SnackBar(
                                    content: Text('Porfavor elige un almacen en el menu de los tres puntos'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  return;
                                }
                                // Acción cuando se hace clic en el elemento de la lista
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InventoryDetailPage(product: product),
                                  ),
                                );
                              },
                              onTapDown: (_) {
                                setState(() {
                                  selectedProductIndex = index;
                                });
                              },
                              onTapCancel: () {
                                setState(() {
                                  selectedProductIndex = null;
                                });
                              },
                              child: Container(
                                color: isSelected ? Colors.blue[100] : Colors.white,
                                child: ListTile(
                                  title:
                                      Text('Localización ${product.location ?? ""} \nCantidad: ${product.productsQuantity ?? ""} \nEan: ${product.ean ?? ""}'),
                                  subtitle: const Text(
                                    "",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          }))
                ]))));
  }
}
