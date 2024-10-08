import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
//import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piking/data/local/entity/product_entity.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/model/objects.dart';
import 'package:piking/domain/model/orders.dart';
import 'package:piking/domain/model/orders_products.dart';
import 'package:piking/domain/model/picking_process.dart';
import 'package:piking/domain/response/picking_process_response.dart';
import 'package:piking/domain/picking/transformer/product_transform.dart';
import 'package:piking/domain/provider/process_picking_provider.dart';
import 'package:piking/domain/repository/picking_details_repository.dart';
import 'package:piking/domain/repository/process_picking_repository.dart';
import 'package:piking/domain/repository/serie_lote_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/picking_list_page.dart';
import 'package:piking/presentation/picking_resume.dart';
import 'package:piking/presentation/serie_lote_page.dart';
import 'package:piking/presentation/shared/custom_app_bar.dart';
import 'package:piking/presentation/shared/pagination_picking.dart';
import 'package:piking/vars.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:io';
import 'package:piking/data/remote/repository/process_picking_repository_impl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PickingPage extends StatefulWidget {
  const PickingPage({super.key, required this.idcliente, required this.orders, required this.cajasId, required this.callback}); // : super(key: key);
  final int idcliente;
  final Orders orders;
  final int cajasId;
  final VoidCallback callback;

  @override
  State<PickingPage> createState() => _PickingState();
}

class _PickingState extends State<PickingPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final SharedPreferences prefs;
  List<OrdersProducts> ordersProducts = [];
  List<Map<String, bool>> zeroValues = [];
  List<Map<String, bool>> firstTime = [];
  late SerieLoteList serieLotes = SerieLoteList(serieLoteList: []);
  bool isLoaded = true;
  late PageController pageController;
  int currentPage = 0;
  int totalPage = 0;
  String textWarning = "";

  final _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  final _selectedCamera = -1;
  final _useAutoFocus = true;
  final _autoEnableFlash = true;
  ScanResult? scanResult;

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _notes = TextEditingController();
  TextEditingController codeLocationProductController = TextEditingController();
  TextEditingController manualQuantityController = TextEditingController();
  bool isValidLocation = false;
  //bool isValidBarcode = false;
  late FocusNode focusController;
  bool autofocus = true;
  bool _isDialogShowing = false;
  String quantityType = "";
  int box = 0;
  int pack = 0;
  int ud = 0;
  bool readOnly = true;
  TextEditingController pickingEditCode = TextEditingController();
  List<String> pickingCode = [];
  List<PickingStatus> pickingStatus = [];
  List<PickingUds> pickingUds = [];
  bool iseErrorBarcode = false;
  bool isValidBarcode = false;
  String quantityTxt = "";
  int firstQuantityBoxPackUd = 0;
  String firstQuantityType = "";
  int udsBox = 0; //int.parse(product.udsBox) ?? 0;
  int udsPack = 0;
  int currentQuantity = 0;
  PickingUds pickingUd = PickingUds(ordersProductsId: 0, quantity: 0, quantityTxt: "", uds: 0);
  int productsQuantity = 0;
  QuantityAndType quantityAndType = QuantityAndType(quantity: 0, type: "", text: "");
  String barcode = "";
  List<int> itemListQuantity = [];
  TextInputType keyboardTypeController = TextInputType.number;
  List<FocusNode> focusInputsControllers = [];
  late bool isConnected = false;
  String quantityTxtTocomplete = "";

  final List<String> itemsPages = List.generate(20, (index) => 'Elemento $index');
  final ScrollController _gridScrollcontroller = ScrollController();
  List<TextEditingController> codeLocationProductControllers = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  ///var index = 0;

  // local data
  var productRepository = di.get<ProductRepository>();
  // remote data
  var pickingDetailsRepository = di.get<PickingDetailsRepository>();
  // serie lote
  var serieLoteRepository = di.get<SerieLoteRepository>();
  //process picking
  var processPickingRepository = di.get<ProcessPickingRespository>();


  getOrdersProducts() async {
    prefs = await _prefs;
    PickingVars.USERSKU = prefs.getString("code1").toString();
    PickingVars.IDCLIENTE = prefs.getInt("IDCLIENTE")!;
    await checkInternetConnection();

    // // ignore: use_build_context_synchronously
    // final processPickingProvider = Provider.of<ProcessPickingProvider>(context, listen: false);
    var pickings = await productRepository.getByOrdersId(int.parse(widget.orders.ordersId.toString()));

    if(pickings.length > 3){
      log("Pickings: ${pickings[2].toJson()}");
    }
    
    if (pickings.isEmpty && isConnected) {
      ordersProducts = await (pickingDetailsRepository.getOrdersProducts(widget.idcliente, int.parse(widget.orders.ordersId.toString()), widget.cajasId));
      //ordersProducts = (await processPickingProvider.getOrdersProducts(widget.idcliente, int.parse(widget.orders.ordersId.toString()), widget.cajasId)).body;
      if (mounted) {
        //log("ordersProducts: $ordersProducts");

        setState(() {
          focusInputsControllers = [];
          codeLocationProductControllers = [];
          // ignore: avoid_function_literals_in_foreach_calls
          ordersProducts.forEach((item) async {
            Map<String, bool> fistTimeElemnt = {"value": true};
            firstTime.add(fistTimeElemnt);
            Map<String, bool> zeroValueElement = {"value": false};
            zeroValues.add(zeroValueElement);
            pickingStatus.add(PickingStatus(ordersProductsId: int.parse(item.ordersProductsId), status: false));
            focusInputsControllers.add(FocusNode());
            codeLocationProductControllers.add(TextEditingController());

            var productEntity = Product(
                item.ordersProductsId.toString(), //
                item.ordersId,
                item.ordersSku.toString(),
                item.productsId.toString(),
                item.productsSku.toString(),
                item.barcode.toString(),
                item.referencia,
                item.productsName,
                item.productsQuantity.toString(),
                item.image,
                item.piking.toString(),
                item.location,
                item.locationId,
                item.quantityProcessed!,
                item.serieLote,
                item.udsPack,
                item.udsBox,
                item.pickingCode,
                item.stock.toString());

            var entity = await productRepository.getProductById(int.parse(item.ordersProductsId));
            if (kDebugMode) {
              print(
                  "Find picking: ${entity?.ordersProductsId} -- ${entity?.ordersProductsId == null}-- buscado ${item.ordersProductsId.toString()} -- ${entity?.ordersProductsId == item.ordersProductsId}");
            }

            if (entity?.ordersProductsId == null && int.parse(item.piking.toString()) == 0) {
              //print("Insertamos producto");
              try {
                productRepository.insertProduct(productEntity);
                isLoaded = false;
              } catch (e) {
                log("Error database insert: $e");
              }
            }
            item.toEmptyData();
          });
          if (ordersProducts.isNotEmpty) {
            List<String> pickCode = (ordersProducts[0].pickingCode).split(",");
            for (var item in pickCode) {
              if (!pickingCode.contains(item)) {
                pickingCode.add(item);
              }
            }
          }

          isLoaded = false;
          totalPage = ordersProducts.length;
        });
      }
    } else {
      if (mounted) {
        focusInputsControllers = [];
        codeLocationProductControllers = [];
        setState(() {
          for (Product item in pickings) {
            Map<String, bool> fistTimeElemnt = {"value": true};
            firstTime.add(fistTimeElemnt);
            Map<String, bool> zeroValueElement = {"value": false};
            zeroValues.add(zeroValueElement);

            ordersProducts.add(productDtoToBodyProduct(item));

            pickingStatus.add(PickingStatus(ordersProductsId: int.parse(item.ordersProductsId), status: false));

            focusInputsControllers.add(FocusNode());
            codeLocationProductControllers.add(TextEditingController());

            String pickCode = item.pickingCode;

            if (!pickingCode.contains(pickCode)) {
              pickingCode.add(pickCode);
            }
          }
          totalPage = ordersProducts.length;
          isLoaded = false;
        });
      }
    }
    // apuntamos el clinete que empieza el picking
    if (ordersProducts.isNotEmpty) {
      PickingProcess pickingProcess = PickingProcess(
          ordersId: widget.orders.ordersId.toString(),
          administratorsSku: PickingVars.USERSKU == "" ? prefs.getString("code1").toString() : PickingVars.USERSKU,
          readedProducts: "0",
          readedLocations: "0",
          dateStart: "",
          dateEnd: "",
          pickingCode: "");
      startWorkWithPicking(pickingProcess);
    }

    //print(ordersProducts.length);
    if (ordersProducts.isEmpty && mounted) {
      Navigator.pop(context);
    }
  }

  static final _possibleFormats = BarcodeFormat.values.toList()..removeWhere((e) => e == BarcodeFormat.unknown);
  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  getSerieLotes() async {
    //List<SerieLotes>
    serieLotes.serieLoteList = (await serieLoteRepository.getSerieLotes(
        int.parse(widget.orders.ordersId.toString()), int.parse(widget.orders.IDCLIENTE.toString()), PickingVars.CAJASID));
  }

  _setProcesedQuantity(String ordersProductsId, int value) {
    List<OrdersProducts> results = [];
    for (var i = 0; i < ordersProducts.length; i++) {
      if (ordersProductsId == ordersProducts[i].ordersProductsId) {
          ordersProducts[i].quantityProcessed = value.toString();
          //actualizar en local las unidades que se tocan
          productRepository.updateQuantityProcessed(int.parse(ordersProductsId), value);

        if (value > 0 && double.parse(ordersProducts[i].productsQuantity.toString()).round() <= double.parse(ordersProducts[i].quantityProcessed.toString()).round()) {
          //picking echo
          ordersProducts[i].piking = "1";
        } else if (value > 0 && double.parse(ordersProducts[i].productsQuantity.toString()).round() > double.parse(ordersProducts[i].quantityProcessed.toString()).round()){
          // picking parcial
          ordersProducts[i].piking = "2";
        } else {
          // pickin sin hacer
          ordersProducts[i].piking = "0";
        }
        if (value == 0) {
          zeroValues[i]['value'] = true;
        }

        // actualizamos el picking a 1 si esta echo
        productRepository.updatePicking(int.parse(ordersProductsId), int.parse(ordersProducts[i].piking!));
      }
      results.add(ordersProducts[i]);
    }

    setState(() {
      ordersProducts = results;
    });
  }

  void _savePicking() async {
    // ignore: unrelated_type_equality_checks
    var isNotComplete = ordersProducts.any((element) => element.piking == "0");
    // return;
    List readedProducts = [];
    List readedLocations = [];
    String pickingCodeString = "";
    await checkInternetConnection();
    if (isConnected) {
      if (isNotComplete) {
        // ignore: use_build_context_synchronously
        bool result_showDialog = await showDialog(
          context: context,
          builder: (BuildContext context) {
            // ignore: deprecated_member_use
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                //log("onPopInvoked: $didPop");
              },
              child: AlertDialog(
                title: const Text('Atención'),
                content: const Text(
                  'Este Picking NO esta completo, \n¿¿Estas seguro lo quieres finalizar??',
                  style: TextStyle(color: Colors.red),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'SI',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onPressed: () async {
                      if (kDebugMode) {
                        print("Picking Incompleto");
                      }
                      String note =
                          "El usuario ${PickingVars.USERSKU} nombre: ${PickingVars.USERNAME} cerro este picking ${ordersProducts[0].ordersSku} incompleto";
                      await pickingDetailsRepository.savePickingIncomplete(ordersProducts[0].ordersId, note);

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('NO', style: TextStyle(fontSize: 20.0)),
                    onPressed: () async {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, true);
                      return;
                    },
                  ),
                ],
              ),
            );
          },
        );
        if (result_showDialog) {
          if (kDebugMode) {
            print('Presionaste No');
          }
          return;
        }
      }

      for (var item in ordersProducts) {
        // boramos los productos de la base de datos local si se ha hecho el picking en totalidad
        var entityProduct = await productRepository.getProductById(int.parse(item.ordersProductsId));

        if (kDebugMode) {
          print("Piking: ${entityProduct?.picking}");
        }

        if (!isNotComplete &&
            entityProduct?.picking != null &&
            double.parse(entityProduct!.productsQuantity).round() == double.parse(entityProduct.quantityProcessed).round()) {
          productRepository.deleteProduct(entityProduct);
          if (!readedProducts.contains(item.ordersProductsId)) {
            readedProducts.add(item.ordersProductsId);
          }
          if (!readedLocations.contains(item.locationId)) {
            readedLocations.add(item.locationId);
          }
        }
      }
    
      pickingCode.removeWhere((element) => element.isEmpty);
      if (pickingCode.length == 1) {
        pickingCodeString = pickingCode[0];
      } else {
        pickingCodeString = pickingCode.join(",");
      }
      pickingDetailsRepository.savePicking(ordersProducts, pickingCodeString);
      //insertamos datos para finalizar el picking
      PickingProcess pickingProcess = PickingProcess(
          ordersId: ordersProducts[0].ordersId,
          administratorsSku: PickingVars.USERSKU,
          readedProducts: (readedProducts.length).toString(),
          readedLocations: (readedLocations.length).toString(),
          dateStart: "",
          dateEnd: "",
          pickingCode: pickingCodeString);

      processPickingRepository.endPickingProcess(pickingProcess);
      widget.callback();
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: const Text(
              'Internet conection',
              style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
            ),
            content: const Text(
              "No hay conexion a internet.",
              style: TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Color.fromARGB(255, 247, 247, 248), fontSize: 20.0),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    // guardamos la serie lote
    //serieLoteRepository.saveSerieLote(int.parse(widget.orders.ordersId.toString()), serieLotes);

    // ignore: use_build_context_synchronously
    Navigator.pop(context, int.parse(ordersProducts[0].ordersId));
    //Navigator.pop(context, "reload");
    return;
  }

  Future<void> checkInternetConnection() async {
    var isOnline = await InternetConnectionChecker().hasConnection;
    setState(() {
      isConnected = isOnline;
    });
  }

  @override
  initState() {
    super.initState();
    getOrdersProducts();
    //getSerieLotes();
    focusController = FocusNode();

    pageController = PageController(initialPage: currentPage);
    if (Platform.isAndroid || Platform.isIOS) {
      Future.delayed(Duration.zero, () async {
        _numberOfCameras = await BarcodeScanner.numberOfCameras;
      });
    }
    checkInternetConnection();
    //_askPermission();
  }

  @override
  void dispose() {
    pageController.dispose();
    focusController.dispose();
    //_db.product.deleteAll();
    //_db.close();
    //productRepository.truncateTable();
    //productRepository.deleteTable();
    pickingUds = [];
    super.dispose();
  }
  Future<void> _askPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }
  Future<void> _takePicture(String Ean) async {
    try {
      await _initializeControllerFuture;
   
      final String fileName = Ean;//DateTime.now().millisecondsSinceEpoch.toString();

      // pattern package.
      final image = await _cameraController!.takePicture();
    
      final bytes = await image.readAsBytes();
      final result = await ImageGallerySaver.saveImage(bytes, quality: 80, name: fileName);
      print("imageGalerySave: $result");

      print('Picture saved to ${image.path}');
    } catch (e) {
      print(e);
    }
  }
  Future<void> _initCamera(String Ean) async {
    // Pedir permiso de cámara
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    // Solicitar permiso para acceder a la carpeta DCIM
    final statusStorage = await Permission.storage.status;
    if(!statusStorage.isGranted){
      await Permission.storage.request();
    }
    // solicitar permiso external storage
    final statusExternalStorage = await Permission.manageExternalStorage.status;
    if(!statusExternalStorage.isGranted){
      await Permission.manageExternalStorage.request();
    }

    // Inicializar cámara
    final cameras = await availableCameras();
    log("camaras: ${cameras}");
    final firstCamera = cameras.first;
    //final secondCamera = cameras.single;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
  
    _initializeControllerFuture = _cameraController!.initialize();

    // Tomar una foto automáticamente después de la inicialización
    _initializeControllerFuture!.then((_) => _takePicture(Ean));
  }

  Widget _buildPageView(BuildContext context) {
    List<Widget> ordersProductsPages = [];
    final processPickingProvider = Provider.of<ProcessPickingProvider>(context);
    if (isLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 20, 73, 187),
        ),
      );
    } else {
      
      var singleWhere = pickingStatus.singleWhere((obj) => obj.ordersProductsId == int.parse(ordersProducts[currentPage].ordersProductsId),
          orElse: () => PickingStatus(ordersProductsId: 0, status: false));
      PickingStatus pickingStatusLocal = singleWhere;
      if (ordersProducts.isEmpty) {
        return Text("Error picking vacio");
      }
      setState(() {
        udsBox = ordersProducts[currentPage].udsBox.isEmpty ? 0 : int.parse(ordersProducts[currentPage].udsBox);
        udsPack = ordersProducts[currentPage].udsPack.isEmpty ? 0 : int.parse(ordersProducts[currentPage].udsPack);
        totalPage = ordersProducts.length;
        currentQuantity = double.parse(ordersProducts[currentPage].quantityProcessed.toString()).round();

        quantityAndType = QuantityAndType(quantity: 0, type: "", text: "");
        if (currentQuantity > 0) {
          quantityAndType = getQuantity(currentQuantity, udsBox, udsPack);
          quantityAndType.quantity = currentQuantity;
          quantityType = "${quantityAndType.text}";
        }

        if (currentQuantity < double.parse(ordersProducts[currentPage].productsQuantity.toString()).round()) {
          isValidBarcode = false;
          pickingStatusLocal.status = false;
        }
        if (currentQuantity == double.parse(ordersProducts[currentPage].productsQuantity.toString()).round()) {
          isValidBarcode = true;
          pickingStatusLocal.status = true;
        }
        
        if (double.parse(ordersProducts[currentPage].productsQuantity.toString()).round() > 0) {
          var quantityToComplete = getQuantityProduct(double.parse(ordersProducts[currentPage].productsQuantity.toString()).round(), udsBox, udsPack);
          quantityTxtTocomplete = quantityToComplete.text;
        }
      });

      itemListQuantity = List.generate(double.parse(ordersProducts[currentPage].productsQuantity.toString()).round() + 1, (index) => index);
      
      SerieLotes series = SerieLotes(ordersProductsId: "", serieLoteItem: []);
      focusInputsControllers[0].requestFocus();

      return PageView.builder(
        itemCount: ordersProducts.length,
        controller: pageController,
        onPageChanged: (int page) async {
          log("Product page det: $page - ${jsonEncode(ordersProducts[page])}");
          OrdersProducts product = ordersProducts[page];
          var quantityProcessed = double.parse(product.quantityProcessed!).round();
          productsQuantity = double.parse(product.productsQuantity.toString()).round();
          barcode = product.barcode;

          currentQuantity = quantityProcessed;
          udsBox = product.udsBox.isEmpty ? 0 : int.parse(product.udsBox);
          udsPack = product.udsPack.isEmpty ? 0 : int.parse(product.udsPack);
          
          if (currentQuantity > 0) {
            quantityAndType = getQuantity(currentQuantity, udsBox, udsPack);
          } else {
            quantityAndType.text = "";
          }
          itemListQuantity = List.empty();

          itemListQuantity = List.generate(double.parse(product.productsQuantity.toString()).round() + 1, (index) => index);

          focusController.requestFocus();

          // miramos a ver a quien pertenece el picking cuando se cambia de pagina
          checkIfPickingTaked(processPickingProvider, product.ordersId);

          setState(() {
            currentQuantity = quantityProcessed;
            quantityType = quantityAndType.text == "" ? "" : quantityAndType.text;
            currentPage = page;
            textWarning = "";
            isValidLocation = false;
            isValidBarcode = false;
            codeLocationProductController.text = "";
            autofocus = true;
            box = 0;
            pack = 0;
            ud = 0;
            if (productsQuantity > 0) {
              var quantityToComplete = getQuantityProduct(productsQuantity, udsBox, udsPack);
              quantityTxtTocomplete = quantityToComplete.text;
            }
          });
        },
        itemBuilder: (context, index) {
          //print("Index: $index - ${ordersProductsPages.length}");
          final product = ordersProducts[currentPage];
          var products = ordersProducts;
          var ordersSku = ordersProducts[0].ordersSku;
          barcode = product.barcode;
          autofocus = true;

          List<Text> pickingCodeWidget = [];
          pickingCode.removeWhere((element) => element.isEmpty || element == "");
          for (var item in pickingCode) {
            if (item.isNotEmpty || item != "") {
              pickingCodeWidget.add(Text(item.replaceAll(RegExp(r'\r|\n'), '')));
            }
          }
          
          focusController.requestFocus();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  children: [
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
                            flex: 7,
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
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: product.barcode));
                                  },
                                  child: StyledText(
                                    text: '<bold>Ean:</bold> <name>${product.barcode}</name>',
                                    tags: {
                                      'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                      'name': StyledTextTag(style: const TextStyle(fontSize: 20))
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                StyledText(
                                  text: '<bold>Loc:</bold> <name>${product.location}</name>',
                                  tags: {
                                    'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                    'name': StyledTextTag(style: const TextStyle(fontSize: 20))
                                  },
                                ),
                                const SizedBox(height: 10,),
                              
                              ],
                            ),
                          ),
                          const SizedBox(width: 0.0),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                                height: 120.0,
                                child: product.image != "" && isConnected
                                    ? Image.network(
                                        "${PickingVars.URL_IMAGE}${product.image}&w=100&h=100",
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error, color: Colors.red),
                                              Text('Error al cargar la imagen'),
                                            ],
                                          );
                                        },
                                      )
                                    : Image.asset("assets/statics/no_image.png")),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, right: 8.0, bottom: 4.0, left: 8.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 140.0,
                            child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: currentQuantity == 0
                                      ? Colors.white
                                      : currentQuantity < double.parse(product.productsQuantity.toString()).round()
                                          ? Colors.amber
                                          : Colors.green,
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 10,
                                      color: Color(0x19000000),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField(
                                  hint: Text("${product.productsQuantity ?? 0}",
                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0)),
                                  decoration: InputDecoration(
                                    labelText: 'Ud: ${product.productsQuantity ?? 0}',
                                    labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26.0),
                                    // Etiqueta descriptiva
                                  ),
                                  value: currentQuantity,
                                  items: itemListQuantity.reversed.map(buildMenuItem).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      currentQuantity = value!;
                                      _setProcesedQuantity(product.ordersProductsId, value);
                                      firstTime[index]['value'] = false;
                                      if (value == 0) {
                                        pickingUd.uds = 0;
                                        pickingUd.quantityTxt = "";
                                        quantityType = "";
                                        pickingStatusLocal.status = false;
                                        isValidBarcode = false;
                                      }
                                    });
                                  },
                                )),
                          ),
                        ),
                        Align( 
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 40,
                            child: IconButton(onPressed: () async {
                                manualQuantityController.text = product.productsQuantity!;
                                await showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text(
                                      'Cambio manual de unidades',
                                      style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 5, 5, 5)),
                                    ),
                                    content: TextField(
                                      autofocus: autofocus,
                                      keyboardType: keyboardTypeController,
                                      controller: manualQuantityController,
                                      decoration: InputDecoration(
                                        labelText: 'Ingresar unidades',
                                        prefixIcon: IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                             
                                              if(manualQuantityController.text == ""){
                                                manualQuantityController.text = "0";
                                              }
                                              
                                              var quantity = double.parse(manualQuantityController.text).round() - 1;
                                              if(quantity < 0){
                                                quantity = 0;
                                              }
                                              manualQuantityController.text = quantity.toString();
                                            });
                                          },
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              
                                              if(manualQuantityController.text == ""){
                                                manualQuantityController.text = "0";
                                              }
                                              var quantity = double.parse(manualQuantityController.text).round() + 1;
                                              manualQuantityController.text = quantity.toString();
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.blue)),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: Theme.of(context).textTheme.bodyLarge,
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'GUARDAR',
                                          style: TextStyle(color: Color.fromARGB(255, 239, 240, 245), fontSize: 20.0),
                                        ),
                                        onPressed: () async {
                                          if(manualQuantityController.text != ""){
                                            int manualQuantity = int.parse(manualQuantityController.text);
                                            try{
                                              productRepository.updateProductsQuantity(int.parse(product.ordersProductsId), manualQuantity);
                                              productRepository.updateQuantityProcessed(int.parse(product.ordersProductsId), manualQuantity);

                                            } catch (e, stackTrace) {
                                              log("Error exception database: $e");
                                              log("Error: $stackTrace");
                                            }
                                            setState(() {
                  
                                              currentQuantity = int.parse(manualQuantityController.text);
                                              product.quantityProcessed = manualQuantityController.text;
                                              product.productsQuantity = manualQuantityController.text;
                                              product.piking = "1";
                                              manualQuantityController.text = "";
                                              
                                            });

                                          }
    
                                          Navigator.pop(context, false);
                                        },
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: Theme.of(context).textTheme.bodyLarge,
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'CERRAR',
                                          style: TextStyle(color: Color.fromARGB(255, 239, 240, 245), fontSize: 20.0),
                                        ),
                                        onPressed: () async {
                                    
                                            setState(() {
                
                                              manualQuantityController.text = "";
                                              
                                            });
                              
                                          Navigator.pop(context, false);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              }, 
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            ),
                          ),  
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 140.0,
                            height: 80.0,
                            child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
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
                                child: TextButton(
                                    onPressed: () async {
                                      List<StockLocations> stockLocationsList =
                                          await (processPickingRepository.findStockLocations(PickingVars.IDCLIENTE.toString(), product.productsId));
                                      //log("stockLocationsList: ${stockLocationsList}");
                                      if (stockLocationsList.isNotEmpty) {
                                        String textStockLocations =
                                            "<bold>${product.productsSku}</bold> / <bold>${product.referencia}</bold>\n<bold>${product.productsName}</bold>\n\n";
                                        var sin_ubicar = 0;
                                        int idx = 0;
                                        for (var item in stockLocationsList) {
                                          if (idx == 0) {
                                            textStockLocations += "<bold>RESUMEN STOCK</bold>:\n";
                                          }

                                          textStockLocations +=
                                              "\t\t${item.cajasAlias} ${item.cajasName.toLowerCase()} => ${item.productsQuantity}ud\n";
                                          idx++;
                                        }
                                        int idy = 0;
                                        for (var item in stockLocationsList) {
                                          if (idy == 0) {
                                            textStockLocations += "\n<bold>RESUMEN STOCK UBICACIONES</bold>:\n";
                                          }
                                          if (item.location.isNotEmpty) {
                                            textStockLocations += " \t\t${item.location} => ${item.quantity}ud\n";
                                          }

                                          sin_ubicar += item.productsQuantity - item.quantity;

                                          idy++;
                                        }

                                        textStockLocations += " \t\tSIN UBICAR => $sin_ubicar ud\n";
                                        // ignore: use_build_context_synchronously
                                        await showDialog(
                                          // ignore: use_build_context_synchronously
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text(
                                                'Información Stock y ubicaciones',
                                                style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 5, 5, 5)),
                                              ),
                                              content: StyledText(text: textStockLocations, tags: {
                                                'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
                                              }),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: Theme.of(context).textTheme.bodyLarge,
                                                    backgroundColor: Colors.blueAccent,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  child: const Text(
                                                    'CERRAR',
                                                    style: TextStyle(color: Color.fromARGB(255, 239, 240, 245), fontSize: 20.0),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context, false);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    style: const ButtonStyle(), //
                                    child: Text("${product.udsBox} Caja\n${product.udsPack} Pack\n${product.stock} stock"))),
                          ),
                        )
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                      child: Row(children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            focusNode: focusController, //focusInputsControllers[index],
                            autofocus: autofocus,
                            keyboardType: keyboardTypeController,
                            controller: codeLocationProductController,
                            decoration: InputDecoration(
                              labelText: 'Ingresar loc/ean/cod. picking',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    codeLocationProductController.text = "";
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: iseErrorBarcode ? Colors.red : Colors.blue)),
                            ),
                            onTap: () {
                              setState(() {
                                keyboardTypeController = TextInputType.number;
                              });
                            },
                            onTapOutside: (outside) {
                              //print("OUTSIDE: $outside");
                              setState(() {});
                            },
                            onEditingComplete: () {
                              // if (codeLocationProductController.text.contains("222")) {
                              //   ///22200001
                              //   String pickCode = codeLocationProductController.text.replaceAll('\n',
                              //       ''); //getPickingCode(codeLocationProductController.text).toString(); //getNumZero(codeLocationProductController.text);
                              //   if (codeLocationProductController.text != "" && !pickingCode.contains(pickCode)) {
                              //     pickingCode.add(pickCode);
                              //   }
                              // }
                            },
                            onChanged: (value) async {
                              //print("value: $value");
                              _initCamera(value);
                              PickingStatus pickingStatusLocal =
                                  pickingStatus.singleWhere((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));

                              QuantityAndType quantityAndType = QuantityAndType(quantity: 0, type: "", text: "");
                              codeLocationProductController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: codeLocationProductController.text.length,
                              );
                              if (value.contains("111") && value.startsWith("111")) {
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
                              } else if (value.contains("222") && value.startsWith("222")) {
                                //if (value.length == 12) {

                                String pickCode = value.replaceAll(RegExp(r'\r|\n'), '').trim();
                                if (value != "" && !pickingCode.contains(pickCode)) {
                                  InserPickingCodeResponse inserPickingCodeResponse =
                                      await processPickingProvider.insertPickingCode(pickCode, product.ordersId);
                                  if (inserPickingCodeResponse.status) {
                                    pickingCode.add(pickCode);
                                    await productRepository.updatePickingCode(int.parse(product.ordersProductsId), pickCode);
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.red,
                                          title: const Text(
                                            'Asignación codígo picking',
                                            style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                                          ),
                                          content: Text(
                                            inserPickingCodeResponse.message,
                                            style: const TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: Theme.of(context).textTheme.bodyLarge,
                                                backgroundColor: Colors.blueAccent,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text(
                                                'Cerrar',
                                                style: TextStyle(color: Color.fromARGB(255, 248, 248, 250), fontSize: 20.0),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    focusController.requestFocus();
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "El codígo picking ya esta asignado a este producto",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 10, //
                                      backgroundColor: const Color.fromARGB(255, 250, 2, 2),
                                      textColor: const Color.fromARGB(255, 184, 183, 183),
                                      fontSize: 16.0);
                                  focusController.requestFocus();
                                }
                                codeLocationProductController.text = "";
                                //}
                              } else {
                                
                                if (barcode == value) {
                                  setState(() {
                                    currentQuantity = double.parse(product.quantityProcessed.toString()).round();
                                    productsQuantity = double.parse(product.productsQuantity.toString()).round();
                                    var udsMissing = productsQuantity - currentQuantity;
                                    quantityType = "";
                                  
                                    var existPickingUds = pickingUds.any((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));

                                    if (udsMissing == 0) {
                                      // audio
                                      try {
                                        AssetsAudioPlayer.newPlayer().open(
                                          Audio("assets/audio/error-in-the-file-system.mp3"),
                                          autoStart: true,
                                          showNotification: true,
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.red,
                                              title: const Text(
                                                'Ud completas',
                                                style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                                              ),
                                              content: const Text(
                                                "No hay que cojer más ud.",
                                                style: TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text(
                                                    'Cerrar',
                                                    style: TextStyle(color: Color.fromARGB(255, 0, 45, 248)),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } catch (t) {
                                        //mp3 unreachable
                                      }
                                    }
                                    
                                    if (currentQuantity <= productsQuantity && udsMissing != 0) {
                                      if (existPickingUds) {
                                        pickingUd = pickingUds.firstWhere((obj) => obj.ordersProductsId == int.parse(product.ordersProductsId));
                                      }

                                      if (currentQuantity > 0) {
                                        
                                        if (udsMissing >= udsBox && udsBox > 0) {
                                          currentQuantity += udsBox;
                                        } else if (udsMissing >= udsPack && udsPack > 0) {
                                          currentQuantity += udsPack;
                                        }
                                        if ((udsMissing < udsBox || udsBox == 0) && (udsMissing < udsPack || udsPack == 0)) {
                                          currentQuantity += 1;
                                        }
                                        quantityAndType = getQuantity(currentQuantity, udsBox, udsPack);
                                        quantityType = " ${quantityAndType.text}";
                                      } else {
                                        if (udsMissing >= udsBox && udsBox > 0) {
                                          currentQuantity = udsBox;
                                          quantityType = " 1 Caja";
                                        } else if (udsMissing >= udsPack && udsPack > 0) {
                                          currentQuantity = udsPack;
                                          quantityType += " 1 Pack";
                                        }
                                        if ((udsMissing < udsBox || udsBox == 0) && (udsMissing < udsPack || udsPack == 0)) {
                                          currentQuantity = 1;
                                          quantityType += "1 Ud";
                                        }
                                      }

                                      if (currentQuantity > productsQuantity) {
                                        currentQuantity = productsQuantity;
                                      }

                                      _setProcesedQuantity(product.ordersProductsId, currentQuantity);
                                    }

                                    if (currentQuantity == double.parse(product.productsQuantity.toString()).round()) {
                                      pickingStatusLocal.status = true;
                                    }
                                  });
                                  //await Future.delayed(const Duration(seconds: 1));
                                  setState(() {
                                    value = "";
                                    codeLocationProductController.text = "";
                                  });
                                  if (currentQuantity == productsQuantity) {
                                    AssetsAudioPlayer.newPlayer().open(
                                      Audio("assets/audio/sound-alert-quantity-comlete.mp3"),
                                      autoStart: true,
                                      showNotification: true,
                                    );

                                    if ((currentPage + 1) == totalPage) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return PickingResume(
                                              ordersProducts: products,
                                              ordersSku: ordersSku,
                                              pageController: pageController,
                                              pickingCode: pickingCode,
                                              internalNotes: widget.orders.internalNotes,
                                              callback: _savePicking);
                                        }),
                                      );
                                    } else {
                                      pageController.jumpToPage(currentPage + 1);
                                    }
                                  }
                                } else {
                                  setState(() {
                                    pickingStatusLocal.status = false;
                                  
                                    iseErrorBarcode = true;
                                    try {
                                      AssetsAudioPlayer.newPlayer().open(
                                        Audio("assets/audio/error.mp3"),
                                        autoStart: true,
                                        showNotification: true,
                                      );
                                    } catch (t) {
                                      //mp3 unreachable
                                    }

                                    int index = products.indexWhere((obj) => obj.barcode == value);
                                    //print("Index error product: $index");
                                    if (index == -1) {
                                      pickingUd.quantity = 0;
                                      Fluttertoast.showToast(
                                          msg: "Error: El codigo ean que se ha introducido es erroneo. No pertenece a este picking",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 10, //
                                          backgroundColor: const Color.fromARGB(255, 250, 2, 2),
                                          textColor: const Color.fromARGB(255, 184, 183, 183),
                                          fontSize: 16.0);

                                      value = "";
                                      codeLocationProductController.text = "";
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            //backgroundColor: Colors.red[100],
                                            title: const Text(
                                              'Error',
                                              style: TextStyle(fontSize: 20.0),
                                            ),
                                            content: const Text(
                                              "El codigo ean que se ha introducido es erroneo.",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Ir al producto'),
                                                onPressed: () async {
                                                  // // ignore: use_build_context_synchronously
                                                  pageController.jumpToPage(index);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      setState(() {
                                        value = "";
                                        codeLocationProductController.text = "";
                                      });
                                    }
                                   
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Center(
                          child: ImageIcon(
                            const AssetImage('assets/icons/location.png'),
                            size: 50.0,
                            color: isValidLocation ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Expanded(
                          child: Container(
                            height: 50.0,
                            //color: Colors.green,
                            alignment: Alignment.topRight,
                            child: Text(
                              quantityType,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                            //flex: 1,
                            child: Container(
                              height: 50.0,
                              //color: Colors.blue,
                              alignment: Alignment.topLeft,
                              child: Text(
                                quantityTxtTocomplete,
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
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
                              width: 95.0,
                              child: Text("Id Cod.Picking", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
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
              //_pagination()
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 40.0,
                      color: const Color.fromARGB(255, 23, 144, 243),
                      onPressed: () {
                        pageController.previousPage(duration: Durations.medium1, curve: Curves.bounceIn);
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ordersSku,
                        style: const TextStyle(color: Color.fromARGB(255, 23, 144, 243), fontSize: 20.0),
                      )),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${currentPage + 1} / $totalPage",
                        style: const TextStyle(color: Color.fromARGB(255, 23, 144, 243), fontSize: 25.0),
                      )),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          //backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 23, 144, 243),
                        ),
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return PickingResume(
                                  ordersProducts: products,
                                  ordersSku: ordersSku,
                                  pageController: pageController,
                                  pickingCode: pickingCode,
                                  internalNotes: widget.orders.internalNotes,
                                  callback: _savePicking);
                            }),
                          );
                          print("Result back navigate: $result");
                          if (result != null && result != 'reload') {
                            if (result is List) {
                              pickingCode = [];
                              for (var element in result) {
                                pickingCode.add(element.toString());
                              }
                            } else if (result is int) {
                              pageController.jumpToPage(result);
                            } else if (result is String && result == "picking") {
                              _savePicking();
                            }
                          }
                        },
                        child: const Text("Resumen"),
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      iconSize: 40.0,
                      color: const Color.fromARGB(255, 23, 144, 243),
                      onPressed: () {
                        pageController.nextPage(duration: Durations.medium1, curve: Curves.bounceIn);
                      },
                    ),
                  )
                ],
              )
            ],
          );

          //return _buildProductDetails(ordersProducts, product, index, widget.orders.ordersSku!); // Pasar el índice del producto
          // return PickingPageItem(
          //     product: product,
          //     currentPage: currentPage,
          //     ordersSku: widget.orders.ordersSku!,
          //     pageController: pageController,
          //     totalPage: totalPage,
          //     pickingCode: pickingCode,
          //     serieLotes: serieLotes,
          //     pickingStatus: pickingStatus);
        },
      );
    }
  }

  DropdownMenuItem<int> buildMenuItem(int item) => DropdownMenuItem(value: item, child: Text("$item"));

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

  SerieLotes _serieLoteProcess(String ordersProductsId, List<SerieLoteItem> serieLoteItem) {
    late SerieLotes serie = SerieLotes(ordersProductsId: "", serieLoteItem: []);
    if (serieLotes.serieLoteList.isNotEmpty) {
      print("serieLotes _serieLoteProcess: ${serieLotes.serieLoteList.length}");

      serie = serieLotes.serieLoteList.firstWhere((e) => e.ordersProductsId == ordersProductsId, //
          orElse: () => SerieLotes(ordersProductsId: "", serieLoteItem: []));

      print("serie _serieLoteProcess: ${serie.ordersProductsId} - ${serie.serieLoteItem.length}");

      if (serie.serieLoteItem.isEmpty) {
        print("serie new: ${serie.serieLoteItem.length}");
        serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: ordersProductsId, serieLoteItem: serieLoteItem));
      } else {
        serie.serieLoteItem = serieLoteItem;
      }
    } else {
      serieLotes.serieLoteList.add(SerieLotes(ordersProductsId: ordersProductsId, serieLoteItem: serieLoteItem));
    }
    return serie;
  }

  String getNumZero(String text) {
    List<String> characters = text.split('');
    int zeroCount = characters.where((char) => char == '0').length;
    //print(zeroCount);
    var pattern = "0".padLeft(zeroCount, "0");
    return pattern;
  }

  Future<bool> checkCameraAvailability() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return false;
    } else {
      // Aquí puedes continuar con la inicialización de la cámara.
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: deprecated_member_use
    return Scaffold(
      appBar: CustomAppBar(
          icon: const Icon(Icons.arrow_back_ios),
          trailingIcon: null,
          onPressIconButton: () {
            Navigator.pop(context, "1");
          },
          idcliente: widget.idcliente,
          title: "Picking",
          onActionPressed: () {}),
      body: _buildPageView(context),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // con esta funcion comporbamos si mientras hacemos el picking alquien lo ha cojido
  checkIfPickingTaked(ProcessPickingProvider processPickingProvider, String ordersId) {
    //log("Llamamos a la funcion para ver quien tiene el picking");
    processPickingProvider.checkTakePicking(ordersId).then((whoOwnsPickingStatus) async {
      //print("processPickingProvider value: $whoOwnsPickingStatus - $_isDialogShowing");
      if (!_isDialogShowing) {
        //print("processPickingProvider.whoOwnsPickingStatus:  ${processPickingProvider.whoOwnsPickingStatus}");
        if (whoOwnsPickingStatus) {
          _isDialogShowing = true;
          // ignore: use_build_context_synchronously
          bool? resultTakePicking = await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  //log("heckIfPickingTake onPopInvoked: $didPop");
                },
                child: AlertDialog(
                  backgroundColor: Colors.red,
                  title: const Text(
                    'Atencion',
                    style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                  ),
                  content: /*Text(
                    "El usuario ${processPickingProvider.whoTakePicking.administratorsName} a las ${processPickingProvider.whoTakePicking.dateUpdate} te ha quitado el PICKING, ¿que quieres hacer? \nNota: Si sales se pierde todo lo que llevas, contacta con tu compañero si hay algun problema.",
                    style: const TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                  ),*/
                      OverflowBar(
                    children: [
                      Text(
                        "El usuario ${processPickingProvider.whoTakePicking.administratorsName} a las ${processPickingProvider.whoTakePicking.dateUpdate} te ha quitado el PICKING, ¿que quieres hacer? \nNota: Si sales se pierde todo lo que llevas, contacta con tu compañero si hay algun problema.",
                        style: const TextStyle(color: Color.fromARGB(255, 245, 248, 245)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text('SALIR'),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text('RECUPERAR'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
          //print("resultTakePicking: $resultTakePicking");
          if (resultTakePicking != null && resultTakePicking) {
            processPickingProvider.takePicking(ordersId);
            processPickingProvider.whoOwnsPickingStatus = false;
            //_isDialogShowing = false;
          } else if (resultTakePicking != null && !resultTakePicking) {
            processPickingProvider.leavePicking(ordersProducts);
            //_isDialogShowing = false;
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PickingListPage(idcliente: PickingVars.IDCLIENTE), // Navigate to another page
              ),
            );
          } else {
            //_isDialogShowing = false;
          }
          _isDialogShowing = false;
        }
      }
    });
  }

  QuantityAndType getQuantity(int udsMissing, int udsBox, int udsPack) {
    QuantityAndType(quantity: 0, type: "", text: "");
    int quantity = 0;
    String type = "";
    String text = "";
    int quantityRemaind = 0;//udsBox == 0 ? udsMissing : udsMissing % udsBox;
    if (udsMissing >= udsBox && udsBox > 0) {
      quantity = udsMissing ~/ udsBox;
      quantityRemaind = udsMissing % udsBox;
      type = "Caja";
      text = "$quantity  de\n";
    } else {
      quantityRemaind = udsMissing;
    }

    // packs
    if (quantityRemaind > 0 && udsMissing >= udsPack && udsPack > 0) {
      quantity = quantityRemaind ~/ udsPack;
      quantityRemaind = quantityRemaind % udsPack;
      type = "Pack";
      text += "$quantity  de\n";
    }
    // unidades
    if (quantityRemaind > 0) {
      quantity = quantityRemaind;
      type = "Ud";
      text += "$quantity  de";
    }
    return QuantityAndType(quantity: quantity, type: type, text: text);
  }

  QuantityAndType getQuantityProduct(int udsMissing, int udsBox, int udsPack) {
    //print("udsProcesarProduct: $udsMissing - udsBox: $udsBox - udsPack: $udsPack");
    QuantityAndType(quantity: 0, type: "", text: "");
    int quantity = 0;
    String type = "";
    String text = "";
    int quantityRemaind = udsBox == 0 ? udsMissing : udsMissing % udsBox;

    if (udsMissing >= udsBox && udsBox > 0) {
      quantity = udsMissing ~/ udsBox;
      quantityRemaind = udsMissing % udsBox;
      type = "Caja";
      text = " $quantity $type \n";
      //print("Box: $text");
    }
    //print("Pack: $quantityRemaind");
    // packs
    if (quantityRemaind > 0 && udsMissing >= udsPack && udsPack > 0) {
      quantity = quantityRemaind ~/ udsPack;
      quantityRemaind = quantityRemaind % udsPack;
      type = "Pack";
      text += " $quantity $type \n";
      //print("Pack: $text");
    }
    //print("Ud: $quantityRemaind");
    // unidades
    if (quantityRemaind > 0) {
      quantity = quantityRemaind;
      type = "Ud";
      text += " $quantity $type";
      //print("Ud: $text");
    }

    //print("getQuantityProduct: $text");
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

  // void Function() createIsolateFunction(SendPort sendPort, String pickingProcess) {
  //   return () {
  //     //startPicking(sendPort, pickingProcess);
  //   };
  // }

  startWorkWithPicking(PickingProcess pickingProcess) async {
    String ordersId = pickingProcess.ordersId;
    String administratorsSku = pickingProcess.administratorsSku;

    processPickingRepository.startPicking(pickingProcess).then((response) async {
      log("response startPicking: ${response.status}");
      if (response.status == false) {
        WhoPickingProcess responseWho = response.whoOwnsPicking; //await processPickingRepository.whoOwnsPicking(ordersId);
        if (responseWho.administratorsSku != administratorsSku) {
          if (mounted) {
            if (!_isDialogShowing) {
              _isDialogShowing = true;
              bool? resultPopup = await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) {
                      //log("onPopInvoked: $didPop");
                    },
                    child: AlertDialog(
                      backgroundColor: Colors.red,
                      title: const Text(
                        'Error',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      content: OverflowBar(children: [
                        Text(
                          "Este picking lo ha empezado el usuario \nSku: ${responseWho.administratorsSku}\nNombre: ${responseWho.administratorsName}\nen esta fecha: ${responseWho.dateStart} \n¿Seguro quieres seguir haciendo el picking?",
                          style: const TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                onPressed: () {
                                  pickingDetailsRepository.saveWhoOverridePicking(
                                      pickingProcess, responseWho.administratorsSku, responseWho.administratorsName);
                                  _isDialogShowing = false;
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Continuar'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () {
                                  _isDialogShowing = false;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => PickingListPage(idcliente: PickingVars.IDCLIENTE), // Navigate to another page
                                    ),
                                  );
                                },
                                child: const Text('Volver'),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  );
                },
              );
              log("resultPopup: $resultPopup");
              if (resultPopup == null) {
                _isDialogShowing = false;
              }
              if (resultPopup == true) {
                _isDialogShowing = false;
              }
            }
          }
        }
      }
    });
  }

}

class PickingUds {
  late int ordersProductsId;
  late String quantityTxt;
  late int quantity;
  late int uds = 0;
  PickingUds({required this.ordersProductsId, required this.quantityTxt, required this.quantity, required int uds});
}

class PickingStatus {
  late int ordersProductsId;
  late bool status;
  PickingStatus({required this.ordersProductsId, required this.status});
} //error-in-the-file-system.mp3

class QuantityAndType {
  late int quantity;
  late String type;
  late String text;
  QuantityAndType({required this.quantity, required this.type, required this.text});
}

class FirstDisabledFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}
