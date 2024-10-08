import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piking/data/local/repository/product_repository.dart';
import 'package:piking/domain/response/languages_reponse.dart';
import 'package:piking/domain/repository/languages_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/login_page.dart';
import 'package:piking/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.idcliente});
  final idcliente;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var languagesRepository = di.get<LanguagesRepository>();
  List<Language> languages = [];
  var currentLanguage = int.parse(PickingVars.languageId);
  // local data
  var productRepository = di.get<ProductRepository>();

  logOut() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove("code1");
    prefs.remove("code2");
    prefs.remove("code3");
    prefs.remove("IDCLIENTE");
    prefs.remove("companyName");
  }

  getLanguages() async {
    languages = await languagesRepository.getLanguages();
    if (mounted) {
      setState(() {
        languages = languages;
        //print("Languges: ${(languages.length)}");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLanguages();
  }

  @override
  Widget build(BuildContext context) {
    //print("languages length: ${languages.length}");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ), //CustomAppBar(idcliente: widget.idcliente, title: "Listado de pickings", onActionPressed: () {}),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: EdgeInsets.all(4.00), //
                      child: Text("Version: ${PickingVars.appVersion.toString()}"))
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Sku: ${PickingVars.USERSKU}", style: const TextStyle(fontSize: 20.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nombre: ${PickingVars.USERNAME}", style: const TextStyle(fontSize: 20.0)),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 220.0,
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
                        hint: const Text("Lenguaje productos"),
                        decoration: const InputDecoration(
                          labelText: 'Lenguaje productos', // Etiqueta descriptiva
                        ),
                        value: currentLanguage,
                        items: languages.map((item) {
                          return DropdownMenuItem(
                            value: item.languagesId,
                            child: Text(item.language),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            currentLanguage = value!;
                            PickingVars.languageId = value.toString();
                          });
                        },
                      )),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Acciones al presionar el botón
                      String result = await productRepository.truncateTable();
                      Fluttertoast.showToast(
                          msg: result,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 30,
                          textColor: Colors.white, //
                          fontSize: 16.0);
                    },
                    child: const Text('Eliminar pickings del dispositivo'),
                  )),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            logOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          tooltip: 'Log out',
          child: const Icon(Icons.exit_to_app),
        ));
  }
}
