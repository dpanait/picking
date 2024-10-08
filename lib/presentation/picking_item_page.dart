import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/domain/model/objects.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/product_model.dart';
import 'package:piking/presentation/picking_page.dart';
import 'package:piking/presentation/serie_lote_page.dart';
import 'package:piking/presentation/shared/pagination_picking.dart';
import 'package:piking/vars.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class PickingPageItem extends StatefulWidget {
  PickingPageItem(
      {super.key,
      required this.product, //
      required this.currentPage,
      required this.ordersSku,
      required this.pageController,
      required this.totalPage,
      required this.pickingCode,
      required this.serieLotes,
      required this.pickingStatus});

  late OrdersProducts product;
  late int currentPage;
  late String ordersSku;
  late PageController pageController;
  late int totalPage;
  late List<String> pickingCode;
  late SerieLoteList serieLotes;
  late List<PickingStatus> pickingStatus;

  @override
  State<PickingPageItem> createState() => _PickingPageItemState();
}

class _PickingPageItemState extends State<PickingPageItem> {
  late int currentPage = widget.currentPage;
  late OrdersProducts product = widget.product;
  late String ordersSku = widget.ordersSku;
  late PageController pageController = widget.pageController;
  late int totalPage = widget.totalPage;
  late List<String> pickingCode = widget.pickingCode;
  FocusNode focusController = FocusNode();
  TextEditingController codeLocationProductController = TextEditingController();
  bool autofocus = true;
  String quantityType = "";
  int box = 0;
  int pack = 0;
  int ud = 0;
  bool readOnly = true;
  TextEditingController pickingEditCode = TextEditingController();
  //List<PickingUds> pickingUds = [];
  late PickingUds pickingUds;
  late SerieLoteList serieLotes = widget.serieLotes;
  late List<PickingStatus> pickingStatus = widget.pickingStatus;
  bool isValidLocation = false;
  String textWarning = "";
  late int currentQuantity = double.parse(product.quantityProcessed!).round();

  @override
  void initState() {
    super.initState();
    pickingUds = PickingUds(ordersProductsId: 0, quantityTxt: "", quantity: 0, uds: 0);
  }

  Widget _buildProductDetails(BuildContext context) {
    print("Product page details: $currentPage - ${jsonEncode(product)}");
    var productsQuantity = double.parse(product.productsQuantity!).round();
    var quantityProcessed = double.parse(product.quantityProcessed!).round();
    //int currentQuantity = quantityProcessed; //quantityProcessed == 0 ? productsQuantity : quantityProcessed;
    List<Text> pickingCodeWidget = [];
    for (var item in pickingCode) {
      pickingCodeWidget.add(Text(item));
    }

    List<int> itemListQuantity = [];
    for (var i = 0; i <= productsQuantity; i++) {
      itemListQuantity.add(i);
    }
    itemListQuantity = itemListQuantity.reversed.toList();
    focusController.requestFocus();

    SerieLotes series = SerieLotes(ordersProductsId: "", serieLoteItem: []);
    //print("Caja: ${product.udsBox} - Pack: ${product.udsPack}");
    //FocusManager.instance.primaryFocus?.unfocus();

    bool isValidBarcode = false;
    var singleWhere = pickingStatus.singleWhere((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));
    PickingStatus pickingStatusLocal = singleWhere;
    isValidBarcode = pickingStatusLocal.status;

    String quantityTxt = "";
    // var pickingUd = pickingUds.singleWhere((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId),
    //     orElse: () => PickingUds(ordersProductsId: 0, quantity: 0, quantityTxt: ""));

    quantityTxt = pickingUds.quantityTxt;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 0),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 50,
                          height: 15,
                          child: StyledText(
                            text: '<bold>$ordersSku</bold>',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 50,
                          height: 15,
                          child: StyledText(
                            text: '<bold>${currentPage + 1}/$totalPage</bold>',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 0, right: 8.0, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: StyledText(
                          text: '<bold>Producto:</bold> <name>${product.productsName}</name>',
                          tags: {
                            'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                            'name': StyledTextTag(style: const TextStyle(fontSize: 16)),
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
                            text: '<bold>Ref:</bold> <name>${product.referencia}</name>',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                              'name': StyledTextTag(style: const TextStyle(fontSize: 20))
                            },
                          ),
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Ean:</bold> <name>${product.barcode}</name>',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                              'name': StyledTextTag(style: const TextStyle(fontSize: 20))
                            },
                          ),
                          const SizedBox(height: 8.0),
                          StyledText(
                            text: '<bold>Loc:</bold> <name>${product.location}</name>',
                            tags: {
                              'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                              'name': StyledTextTag(style: const TextStyle(fontSize: 20))
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
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
                                          labelText: 'Udddd: ${product.productsQuantity ?? 0}', // Etiqueta descriptiva
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
                                            //_setProcesedQuantity(product.ordersProductsId, value);
                                            //firstTime[index]['value'] = false;
                                          });
                                        },
                                      )),
                                ),
                              ),
                              Align( 
                                alignment: Alignment.center,
                                child: IconButton(onPressed: (){
                                    print("click edit");
                                  }, 
                                icon: const Icon(Icons.edit),
                                color: Colors.amber,
                                ),  
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text("${product.udsBox} Caja\n${product.udsPack} Pack"),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                          height: product.image != "" ? 150.0 : 150.0,
                          child: product.image != ""
                              ? /*CachedNetworkImage(
                                  imageUrl: URL_IMAGE + product.image,
                                  placeholder: (context, url) {
                                    // if (kDebugMode) {
                                    //   print("Loader: $url - $URL_IMAGE");
                                    // }

                                    return const SizedBox(width: 100, height: 100, child: CircularProgressIndicator());
                                  }, // Widget de carga
                                  errorWidget: (context, url, error) {
                                    if (kDebugMode) {
                                      print("Errro load image: $url - $error");
                                    }
                                    try {
                                      return Image.asset("assets/statics/no_image.png");
                                    } catch (e) {
                                      // if (kDebugMode) {
                                      //   print("Catch: $e");
                                      // }
                                      return const Text("No image");
                                    }
                                  }, // Widget de error
                                )*/
                              CachedNetworkImage(
                                  imageUrl: PickingVars.URL_IMAGE + product.image,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.cover, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
                                    ),
                                  ),
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) {
                                    try {
                                      return const Icon(Icons.error);
                                    } catch (e) {
                                      var error = e.toString();
                                      return Text(error);
                                    }
                                  },
                                )
                              : Image.asset("assets/statics/no_image.png")),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      focusNode: focusController,
                      readOnly: readOnly,
                      showCursor: true,
                      //autofocus: autofocus,
                      keyboardType: TextInputType.number,
                      controller: codeLocationProductController,
                      decoration: InputDecoration(
                        labelText: 'Ingresar loc/ean/cod. picking',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onTap: () {
                        //print("Tap button");
                        setState(() {
                          readOnly = false;
                        });
                      },
                      onTapOutside: (outside) {
                        //print("OUTSIDE: $outside");
                        setState(() {
                          readOnly = true;
                        });
                      },
                      onEditingComplete: () {
                        if (codeLocationProductController.text.contains("222")) {
                          ///22200001
                          String pickCode = getPickingCode(codeLocationProductController.text).toString(); //getNumZero(codeLocationProductController.text);
                          if (!pickingCode.contains(pickCode)) {
                            pickingCode.add(pickCode);
                          }
                        }
                      },
                      onChanged: (value) {
                        //print("value: $value");
                        PickingStatus pickingStatusLocal = pickingStatus.singleWhere((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));

                        if (value.contains("111")) {
                          //_checkLocationProducts(product.location,value);
                          if (product.locationId == value) {
                            setState(() {
                              isValidLocation = true;
                            });
                          } else {
                            setState(() {
                              isValidLocation = false;
                            });
                          }
                        } else {
                          //_checkLocationProducts(product.barcode,value);
                          print("${product.barcode} - $value");
                          if (product.barcode == value) {
                            setState(() {
                              //quantityType = "";
                              //pickingStatusLocal.status = true;

                              //isValidBarcode = true;
                              var udsMissing = double.parse(product.productsQuantity.toString()).round() - currentQuantity;
                              //print("UdsMissing: $udsMissing");
                              var quantityAndType = getQuantity(
                                  udsMissing, int.parse(product.udsBox), int.parse(product.udsPack)); //int.parse(product.udsBox), int.parse(product.udsPack)
                              //var existPickingUds = pickingUds.any((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));

                              if (udsMissing == 0) {
                                // audio
                                try {
                                  AssetsAudioPlayer.newPlayer().open(
                                    Audio("assets/audio/error-in-the-file-system.mp3"),
                                    autoStart: true,
                                    showNotification: true,
                                  );
                                } catch (t) {
                                  //mp3 unreachable
                                }
                              }
                              if (currentQuantity <= double.parse(product.productsQuantity.toString()).round() && udsMissing != 0) {
                                //currentQuantity += quantityAndType.quantity;

                                if (box > 0) {
                                  quantityType = " $box Caja";
                                }
                                if (pack > 0) {
                                  quantityType += " $pack Pack";
                                }
                                if (ud > 0) {
                                  quantityType += " $ud ud";
                                }
                                //readOnly = true;
                                //if (pickingUds.ordersProductsId != "") {
                                // pickingUd = PickingUds(
                                //     ordersProductsId: int.parse(product.ordersProductsId), //
                                //     quantity: quantityAndType.quantity,
                                //     quantityTxt: quantityType);
                                // pickingUds.add(pickingUd);
                                pickingUds.ordersProductsId = int.parse(product.ordersProductsId);
                                pickingUds.quantity = quantityAndType.quantity;
                                pickingUds.quantityTxt = quantityType;
                                // } else {
                                //   pickingUd.quantity = quantityAndType.quantity;
                                //   pickingUd.quantityTxt = quantityType;
                                // }
                                print("PickingUds: $pickingUds");
                                currentQuantity += pickingUds.quantity;
                                //_setProcesedQuantity(product.ordersProductsId, quantityAndType.quantity);

                                quantityType = "";
                              }

                              if (currentQuantity == double.parse(product.productsQuantity.toString()).round()) {
                                pickingStatusLocal.status = true;
                              }

                              //print("CurrentQuantity:  $currentQuantity - ${quantityAndType.type}- udsBox: ${product.udsBox} - udsPack: ${product.udsPack} - box: $box, pack: $pack, ud: $ud, $quantityType");
                            });
                          } else {
                            setState(() {
                              pickingStatusLocal.status = false;
                              if (value.length == 13) {
                                try {
                                  AssetsAudioPlayer.newPlayer().open(
                                    Audio("assets/audio/error.mp3"),
                                    autoStart: true,
                                    showNotification: true,
                                  );
                                } catch (t) {
                                  //mp3 unreachable
                                }
                              }
                            });
                          }
                        }
                        if (value.contains("222")) {
                          if (value.length == 12) {
                            String pickCode = getPickingCode(codeLocationProductController.text).toString(); //getNumZero(codeLocationProductController.text);
                            if (!pickingCode.contains(pickCode)) {
                              pickingCode.add(pickCode);
                            }
                          }
                        }
                        setState(() {
                          codeLocationProductController.text = value;
                        });
                      },
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Center(
                    child: ImageIcon(
                      const AssetImage('assets/icons/location.png'),
                      size: 48.0,
                      color: isValidLocation ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Expanded(
                      flex: 1,
                      child: Text(
                        quantityTxt,
                        textAlign: TextAlign.center,
                      )),
                  Center(
                      child: ImageIcon(
                    const AssetImage('assets/icons/box.png'),
                    size: 48.0,
                    color: isValidBarcode ? Colors.green : Colors.grey,
                  ))
                ]),
              ),
              const SizedBox(width: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100.0,
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              textWarning = "";
                            });
                            // if (kDebugMode) {
                            //   print("PrductsSku picking: ${product.productsSku}");
                            // }

                            //_showAdaptiveDialog(context, numberOfFields, textControllers);
                            for (var element in serieLotes.serieLoteList) {
                              if (kDebugMode) {
                                print("SerieLote: ${element.ordersProductsId}");
                              }
                            }
                            if (serieLotes.serieLoteList.isNotEmpty) {
                              try {
                                series = serieLotes.serieLoteList.singleWhere(
                                  (e) => e.ordersProductsId == product.ordersProductsId,
                                  orElse: () => SerieLotes(ordersProductsId: "", serieLoteItem: []),
                                );
                              } on Exception catch (_, e) {
                                if (kDebugMode) {
                                  print("No se encuantra: $e");
                                }
                              }

                              // if (kDebugMode) {
                              //   print("Serie picking: ${series.serieLoteItem}");
                              // }
                            }

                            //SerieLotes? result = SerieLotes(product.ordersProductsId, []);
                            //serieLotes.clear();
                            List<SerieLoteItem> result = [];

                            result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SerieLotePage(
                                            ordersProductsId: int.parse(product.ordersProductsId),
                                            productsSku: product.productsSku.toString(),
                                            seriesLote: series,
                                          )),
                                ) ??
                                [];
                            if (result.isNotEmpty) {
                              if (kDebugMode) {
                                print("Data form screen2: $result");
                              }

                              List<SerieLoteItem> serieLotesResult = [];
                              for (var element in result) {
                                serieLotesResult.add(element);
                              }
                              setState(() {
                                //series = _serieLoteProcess(product.ordersProductsId, result);
                                if (serieLotes.serieLoteList.isNotEmpty) {
                                  series = serieLotes.serieLoteList.firstWhere((e) => e.ordersProductsId == product.ordersProductsId,
                                      orElse: () => SerieLotes(ordersProductsId: "", serieLoteItem: []));

                                  if (series.ordersProductsId == "") {
                                    serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: product.ordersProductsId, serieLoteItem: serieLotesResult));
                                  } else {
                                    series.serieLoteItem = serieLotesResult;
                                  }
                                } else {
                                  serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: product.ordersProductsId, serieLoteItem: serieLotesResult));
                                }
                              });

                              if (serieLotes.serieLoteList.isNotEmpty) {
                                for (var element in serieLotes.serieLoteList) {
                                  if (kDebugMode) {
                                    print("SerieLote: OpId: ${element.ordersProductsId} - ${element.serieLoteItem.toString()}");
                                  }
                                }
                              }

                              //print("Serie lote from page: ${jsonEncode(serieLotes)}");
                            }
                          },
                          child: const Text("Serie/Lote")),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 60.0,
                        child: Text(
                          "Id Cod. Picking",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(children: [
                  Expanded(
                      flex: 2,
                      //alignment: Alignment.centerLeft,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: const SingleChildScrollView(
                            child: Column(
                          children: [],
                        )),
                      )),
                  Expanded(
                    flex: 1,
                    //alignment: Alignment.centerRight,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: SingleChildScrollView(
                          child: Column(
                        children: pickingCodeWidget,
                      )),
                    ),
                  )
                ]),
              )
            ],
          )),
        ),
        _pagination()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(idcliente: widget.idcliente, title: "Listado de pickings", onActionPressed: () {}),
      body: _buildProductDetails(context),
    );
  }

  QuantityAndType getQuantity(int udsMissing, int udsBox, int udsPack) {
    QuantityAndType(quantity: 0, type: "", text: "");
    int quantity = 0;
    String type = "";
    String text = "";
    if (udsMissing >= udsBox && udsBox > 0) {
      quantity = udsBox;
      type = "Cajas";
      box++;
    } else if (udsMissing >= udsPack && udsPack > 0) {
      quantity = udsPack;
      type = "Pack";
      pack++;
    }

    if ((udsMissing < udsBox || udsBox == 0) && (udsMissing < udsPack || udsPack == 0)) {
      quantity = 1;
      type = "ud";
      ud++;
    }

    return QuantityAndType(quantity: quantity, type: type, text: text);
  }

  int getPickingCode(String input) {
    // Buscar la posición del primer "0" en el string
    int firstZeroPosition = input.indexOf('0');

    // Si se encuentra el "0", contar la cantidad de ceros que siguen
    if (firstZeroPosition != -1) {
      int cerosDetrasDeDos = int.parse(input.substring(firstZeroPosition + 1));
      return cerosDetrasDeDos;
    } else {
      // Si no se encuentra el "2", devuelve 0
      return 0;
    }
  }

  Widget _pagination() {
    return PaginationPicking(
      onPageChanged: (int pageNumber) {
        //do somthing for selected page
        //print("CurrentPage: $currentPage - numPage: $pageNumber - totalPage: $totalPage");
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
}
