import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piking/domain/model/objects.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/feature/stock/domain/model/stock_entry.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/serie_lote_page.dart';
import 'package:piking/presentation/shared/pagination_picking.dart';
import 'package:piking/vars.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class StockEntryPage extends StatefulWidget {
  final int idcliente;
  final StockEntry orders;
  final int cajasId;
  final VoidCallback callback;

  const StockEntryPage({super.key, required this.idcliente, required this.orders, required this.cajasId, required this.callback});

  @override
  State<StockEntryPage> createState() => _StockEntryPageState();
}

class _StockEntryPageState extends State<StockEntryPage> {
  List<OrdersProducts> ordersProducts = [];
  bool isLoaded = true;
  late PageController pageController;
  int currentPage = 0;
  int totalPage = 0;
  String textWarning = "";
  List<Map<String, bool>> zeroValues = [];
  List<Map<String, bool>> firstTime = [];
  late SerieLoteList serieLotes;

  final _notes = TextEditingController();
  var pickingDetailsRepository = di.get<PickingDetailsRepository>();

  getProducts() async {
    List<OrdersProducts> response = await pickingDetailsRepository.getOrdersProducts(
        widget.idcliente, int.parse(widget.orders.ordersId.toString()), int.parse(widget.orders.cajasId.toString()));
    //(await productsListModel.postProductsList(widget.idcliente, widget.orders.ordersId, widget.orders.cajasId))!;
    setState(() {
      ordersProducts = response;

      totalPage = ordersProducts.length;
      isLoaded = false;
    });
    for (var item in ordersProducts) {
      if (kDebugMode) {
        print("OrdersProducts: ${jsonEncode(item)}");
      }
    }
  }

  _setProcesedQuantity(String ordersProductsId, int value) {
    List<OrdersProducts> results = [];
    for (var i = 0; i < ordersProducts.length; i++) {
      if (ordersProductsId == ordersProducts[i].ordersProductsId) {
        ordersProducts[i].quantityProcessed = value.toString();

        //actualizar en local las unidades que se tocan
        /*productRepository.updateQuantityProcessed(
            int.parse(ordersProductsId), value);*/

        if (value > 0) {
          ordersProducts[i].piking = "1";
        } else {
          ordersProducts[i].piking = "0";
        }
        if (value == 0) {
          zeroValues[i]['value'] = true;
        }

        // actualizamos el picking a 1 si esta echo
        /*productRepository.updatePicking(
            int.parse(ordersProductsId), int.parse(products[i].piking));*/
      }
      results.add(ordersProducts[i]);
    }

    setState(() {
      ordersProducts = results;
    });
  }

  _saveEntryStock() {
    Fluttertoast.showToast(
        msg: "Funcionalidad no implementada",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 15,
        textColor: Colors.white, //
        fontSize: 16.0);
  }

  @override
  initState() {
    super.initState();
    getProducts();
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget _buildPageView(BuildContext context) {
    if (isLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 6, 57, 167),
        ),
      );
    } else if (ordersProducts.isEmpty) {
      return const Column(children: [
        Text("No tenemos productos"),
      ]);
    } else {
      totalPage = ordersProducts.length + 1;

      return PageView.builder(
        itemCount: ordersProducts.length,
        controller: pageController,
        onPageChanged: (int page) {
          //print("PageView: $page");
          setState(() {
            currentPage = page;
            textWarning = "";
          });
        },
        itemBuilder: (context, index) {
          //print("Index: $index - ${ordersProductsPages.length}");
          final product = ordersProducts[index];

          //return ordersProductsPages[index];
          if (ordersProducts.length == currentPage) {
            return _buildPikingFinal(ordersProducts, widget.orders.ordersSku!);
          } else {
            return _buildProductDetails(ordersProducts, product, index, widget.orders.ordersSku!); // Pasar el índice del producto
          }
        },
      );
    }
  }

  Widget _pagination() {
    return PaginationPicking(
      onPageChanged: (int pageNumber) {
        //do somthing for selected page
        setState(() {
          currentPage = pageNumber - 1;
          pageController.jumpToPage(currentPage);
        });
      },
      threshold: 4,
      pageTotal: totalPage,
      pageInit: currentPage + 1, // picked number when init page
      colorPrimary: Colors.blue,
      colorSub: Colors.white,
      fontSize: 32.0,
    );
  }

  Widget _buildProductDetails(List<OrdersProducts> products, OrdersProducts product, int index, String ordersSku) {
    var productsQuantity = double.parse(product.productsQuantity!).round();
    var quantityProcessed = double.parse(product.quantityProcessed!).round();
    int currentQuantity = quantityProcessed; //quantityProcessed == 0 ? productsQuantity : quantityProcessed;
    SerieLotes series = SerieLotes(ordersProductsId: "", serieLoteItem: []);
    List<int> itemListQuantity = [];

    for (var i = 0; i <= productsQuantity; i++) {
      itemListQuantity.add(i);
    }

    if (kDebugMode) {
      print("Network image: ${product.image}");
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: StyledText(
                          text: '<bold>Producto:</bold> ${product.productsName}',
                          tags: {
                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 0.0, right: 10.0, bottom: 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Sku:</bold> ${product.productsSku ?? ""}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Ref:</bold> ${product.referencia}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Ean:</bold> ${product.barcode}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Localización:</bold> ${product.location}',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 120.0,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                            offset: Offset(0, 2),
                                            blurRadius: 10,
                                            color: Color(0x19000000),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonFormField(
                                        hint: Text("${product.productsQuantity ?? 0}"),
                                        decoration: InputDecoration(
                                          labelText: 'Ud: ${product.productsQuantity ?? 0}', // Etiqueta descriptiva
                                        ),
                                        value: currentQuantity,
                                        items: itemListQuantity.map((item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text("$item"),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            currentQuantity = value!;
                                            _setProcesedQuantity(product.ordersProductsId, value);
                                            firstTime[index]['value'] = false;
                                          });
                                        },
                                      )),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                          height: product.image.isEmpty ? 200.0 : 200.0,
                          child: product.image != ""
                              ? CachedNetworkImage(
                                  imageUrl: PickingVars.URL_IMAGE + product.image,
                                  placeholder: (context, url) {
                                    if (kDebugMode) {
                                      print("Loader: $url - ${PickingVars.URL_IMAGE}");
                                    }

                                    return const SizedBox(width: 100, height: 100, child: CircularProgressIndicator());
                                  }, // Widget de carga
                                  errorWidget: (context, url, error) {
                                    if (kDebugMode) {
                                      print("Errro: $url - $error");
                                    }
                                    try {
                                      return Image.asset("assets/statics/no_image.png");
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print("Catch: $e");
                                      }
                                      return const Text("No image");
                                    }
                                    // if (url == URL_IMAGE) {
                                    //   return Image.asset(
                                    //       "assets/statics/no_image.png");
                                    // } else {
                                    //   return const Text("No image");
                                    // }
                                  }, // Widget de error
                                )
                              : Image.asset("assets/statics/no_image.png")
                          /*product.image != ""
                                  ? Image.network("$URL_IMAGE${product.image}")
                                  : Image.asset("assets/statics/no_image.png")
                              *Image.network(
                                                  "https://yuubbb.com/images/${product.image}", // this image doesn't exist
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white60,
                                  alignment: Alignment.center,
                                  child: Image.asset("assets/statics/no_image.png"),
                                );
                              },
                            ),*/
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      StyledText(
                        text: '   <color>$textWarning</color>',
                        tags: {
                          'color': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        },
                      ),
                    ],
                  )),
              const SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          textWarning = "";
                        });
                        /*_scanLocation().then((value) {
                                  if (product.location == value?.rawContent) {
                                  } else {
                                    setState(() {
                                      textWarning =
                                          "La localizacion no es correcta, Comprobar!!";
                                    });
                                  }
                                });*/
                      },
                      child: const Text("Validar localización")),
                  ElevatedButton(
                      onPressed: () async {
                        // QrcodeBarcodeScanner(
                        //   onScannedCallback: (String value) => setState(
                        //     () {
                        //       print("Barcode: $value");
                        //     },
                        //   ),
                        // );
                        //_scanCode();
                        setState(() {
                          textWarning = "";
                        });
                        /*_scanProduct().then((value) {
                                  if (product.barcode == value?.rawContent) {
                                  } else {
                                    setState(() {
                                      textWarning =
                                          "El Producto no es correcto, Comprobar!!";
                                    });
                                  }
                                });*/

                        //scanProduct(product.barcode.toString());
                      },
                      child: const Text("Validar producto"))
                ]),
              ),
              const SizedBox(width: 16.0),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150.0,
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              textWarning = "";
                            });
                            //_showAdaptiveDialog(context, numberOfFields, textControllers);
                            //SerieLotes serie = SerieLotes("", []);
                            if (serieLotes.serieLoteList.isNotEmpty) {
                              series = serieLotes.serieLoteList.firstWhere((e) => e.ordersProductsId == product.ordersProductsId);
                              if (kDebugMode) {
                                print("Serie picking: ${series.serieLoteItem}");
                              }
                            }
                            List<SerieLotes> result = [];
                            result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SerieLotePage(
                                            ordersProductsId: int.parse(product.ordersProductsId),
                                            productsSku: product.productsSku!,
                                            seriesLote: series,
                                          )),
                                ) ??
                                [];
                            if (result.isNotEmpty) {
                              if (kDebugMode) {
                                print("Data form screen2: $result");
                              }
                              //serieLotes = jsonDecode(result);
                              //print("serieLote: $serieLotes");
                              // var groupSerieLote = result[0];
                              // var serieLote = result[1];
                              // var serieLoteGroup = [];
                              // var serieLoteCode = [];
                              List<SerieLoteItem> serieLotesResult = [];
                              for (var element in result[0].serieLoteItem) {
                                serieLotesResult.add(element);
                              }
                              setState(() {
                                if (serieLotes.serieLoteList.isNotEmpty) {
                                  series = serieLotes.serieLoteList.firstWhere((e) => e.ordersProductsId == product.ordersProductsId,
                                      orElse: () => SerieLotes(ordersProductsId: '', serieLoteItem: []));

                                  if (series.ordersProductsId == "") {
                                    serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: product.ordersProductsId, serieLoteItem: serieLotesResult));
                                  } else {
                                    series.serieLoteItem = serieLotesResult;
                                  }
                                } else {
                                  serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: product.ordersProductsId, serieLoteItem: serieLotesResult));
                                }
                              });

                              // setState(() {
                              //   serieLotes.add(SerieLotes(
                              //     product.ordersProductsId,
                              //   ));
                              // });
                            }
                          },
                          child: const Text("Serie/Lote")),
                    ),
                  ],
                ),
              )
            ],
          )),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pagination(),
        )
      ],
    );
  }

  Widget _buildPikingFinal(List<OrdersProducts> products, String ordersSku) {
    List<Card> cardsItems = [];
    Color? colorCard = Colors.green[50];
    isLoaded = false;
    var ordersId = products[0].ordersId;
    //for (var i = 0; i < 10; i++) {
    for (var product in products) {
      var productsQuantity = double.parse(product.productsQuantity!).round();
      var quantityProcessed = double.parse(product.quantityProcessed!).round();

      if (quantityProcessed < productsQuantity) {
        colorCard = Colors.orange[50];
      }
      if (quantityProcessed == 0) {
        colorCard = Colors.white;
      }
      cardsItems.add(Card(
          elevation: 50,
          shadowColor: Colors.black,
          color: colorCard,
          child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StyledText(
                        text: '<bold>Sku:</bold> ${product.productsSku ?? ""}',
                        tags: {
                          'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                        },
                      ),
                      StyledText(
                        text: '<bold> Ref:</bold> ${product.referencia}',
                        tags: {
                          'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                        },
                      ),
                      StyledText(
                        text: '<bold> Ud:</bold> ${product.quantityProcessed ?? ""} <bold>de: </bold> $productsQuantity',
                        tags: {
                          'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                        },
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    StyledText(
                      text: '<bold>Ean:</bold> ${product.barcode}',
                      tags: {
                        'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                      },
                    ),
                  ]),
                  //${product.productsName!.length > 79 ? product.productsName!.substring(0, 80) + '...' : product.productsName}
                  Row(
                    children: [
                      SizedBox(
                        width: 340.0,
                        height: 30.0,
                        child: StyledText(
                          text: '<bold>Nombre:</bold> ${product.productsName}',
                          tags: {
                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StyledText(
                        text: '<bold>Serie/Lote:</bold> ${product.serieLote ?? ""}',
                        tags: {
                          'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                        },
                      ),
                    ],
                  )
                ],
              ))));
      colorCard = Colors.green[50];
    }
    //}

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: cardsItems,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  //Navigator.pop(context);

                  /*for (var i = 0; i < products.length; i++) {
                    if (firstTime[i]['value'] == true) {
                      var product = products[i];
                      var productQuantity =
                          double.parse(product.productsQuantity!).round();
                      _setProcesedQuantity(
                          product.ordersProductsId!, productQuantity);
                    }
                  }*/

                  _saveEntryStock();
                },
                child: const Text('Guardar'),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Notas'),
                        content: TextField(
                          keyboardType: TextInputType.text,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            // Actualizar la variable 'notes'
                            _notes.text = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Guardar'),
                            onPressed: () async {
                              if (kDebugMode) {
                                print("Note: ${_notes.text}");
                              }
                              await pickingDetailsRepository.saveNote(_notes.text, ordersId);
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pagination(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entrada: ${widget.orders.ordersSku}',
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildPageView(context),
    );
  }
}
