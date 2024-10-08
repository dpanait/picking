import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/vars.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  late int idcliente = 0;
  final VoidCallback onActionPressed;
  late Icon? icon;
  late Icon? trailingIcon;
  late VoidCallback onPressIconButton;

  CustomAppBar(
      {super.key,
      required this.idcliente,
      required this.title,
      required this.onActionPressed,
      required this.icon,
      required this.trailingIcon,
      required this.onPressIconButton});
  final String title;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Altura deseada para el AppBar
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Icon? icon;
  late Icon? trailingIcon;
  late VoidCallback onPressIconButton;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var storeRepository = di.get<StoreRepository>();
  StoreResponse storeResponse = StoreResponse(status: false);

  List<Store> stores = [];
  List<PopupMenuItem> storeItem = [];
  late String storeLabel = ""; //PickingVars.CAJASNAME == "" ? "Almacen" : PickingVars.CAJASNAME;

  getAllStore() async {
    storeResponse = await storeRepository.getAllStore(widget.idcliente);
    if (mounted) {
      setState(() {
        storeResponse.body?.forEach((element) {
          stores.add(Store.fromJson(element.toJson()));
        });
      });
    }
  }

  @override
  initState() {
    super.initState();
    getAllStore();
    icon = widget.icon;
    trailingIcon = widget.trailingIcon;

    onPressIconButton = widget.onPressIconButton;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget iconButton() => IconButton(onPressed: onPressIconButton, icon: icon!);

  @override
  Widget build(BuildContext context) {
    storeItem = [];
    for (var i = 0; i < stores.length; i++) {
      storeItem.add(PopupMenuItem<int>(
        value: int.parse(stores[i].cajasId!),
        child: Text(
          "${stores[i].cajasId} - ${stores[i].cajasName ?? stores[i].cajasNameY}",
          style: TextStyle(fontWeight: (PickingVars.CAJASID == int.parse(stores[i].cajasId!)) ? FontWeight.w700 : FontWeight.normal),
        ),
      ));
    }

    return AppBar(
      // leading: IconButton(
      //   icon: icon,
      //   onPressed: () {
      //     ///widget.onActionPressed();
      //     Navigator.pop(context, "1");
      //   },
      // ),
      // ignore: unnecessary_null_comparison
      leading: icon != null ? IconButton(onPressed: onPressIconButton, icon: icon!) : null,
      title: Text(widget.title),
      actions: [
        Align(
          alignment: Alignment.center,
          child: Text(
            storeLabel,
            style: const TextStyle(),
          ),
        ),
        trailingIcon != null
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.onActionPressed,
              )
            : Text("")
        /*PopupMenuButton(
            // add icon, by default "3 dot" icon
            // icon: Icon(Icons.book)
            tooltip: "Almacen",
            itemBuilder: (context) {
              return storeItem;
            },
            onSelected: (value) {
              setState(() {
                //PickingVars.CAJASID = value;
                PickingVars.CAJASID = value;
                Store storeItem = stores.where((str) => str.cajasId != null && int.parse(str.cajasId!) == value).first;
                storeLabel = "${storeItem.cajasId} - ${storeItem.cajasName ?? storeItem.cajasNameY}";
                PickingVars.CAJASNAME = storeLabel;
                widget.onActionPressed();
              });

              if (kDebugMode) {
                print(PickingVars.CAJASID);
              }
            }),*/
      ],
    );
  }
}
