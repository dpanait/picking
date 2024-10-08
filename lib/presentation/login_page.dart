import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piking/data/remote/model/login_response.dart';
import 'package:piking/domain/repository/login_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/picking_list_page.dart';
import 'package:piking/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //late LoginPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late LoginResponse result;
  late TextEditingController _codeController;

  late String _code1;
  late String _code2;
  late String _code3;

  var loginRepository = di.get<LoginRepository>();

  getLogin(code1, code2, code3) async {
    result = await loginRepository.login(code1, code2, code3);
  }

  setLogin(String code1, String code2, String code3, int idcliente, String companyName, String userName) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("code1", code1);
    prefs.setString("code2", code2);
    prefs.setString("code3", code3);
    prefs.setInt("IDCLIENTE", idcliente);
    prefs.setString("companyName", companyName);
    prefs.setString("userName", userName);
  }

  final code1 = "";
  final code2 = "";
  final code3 = "";
  // This widget is the root of your application.
  getLocalLogin() async {
    final SharedPreferences prefs = await _prefs;
    _code1 = prefs.getString("code1") ?? "";
    _code2 = prefs.getString("code2") ?? "";
    _code3 = prefs.getString("code3") ?? "";
    _codeController.text = "$_code1,$_code2,$_code3";
  }

  @override
  initState() {
    super.initState();
    result = LoginResponse(status: false, companyName: "", userName: "");
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: Text("Porfavor insertar codígos separados por coma  ,")),
            ),
            Center(
                child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 150,
                child: TextField(
                  autofocus: true,
                  obscureText: false,
                  controller: _codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Codígos login',
                  ),
                ),
              ),
            ])),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () async {
                      //primero buscamos la version
                      var resultVersion = await loginRepository.getVersion();
                      //print("Result version: $resultVersion");
                      if (PickingVars.ENVIRONMENT == 'pro' && resultVersion != "Erorr") {
                        PickingVars.VERSION = "pro/buy$resultVersion";
                      }
                      if (!_codeController.text.contains(",")) {
                        // ignore: use_build_context_synchronously
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.red,
                                title: const Text(
                                  'Atencion',
                                  style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                                ),
                                content: const Text(
                                  "Los codigos introducidos no estan separados por coma.",
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
                            });
                        return;
                      }
                      List<String> loginCode = _codeController.text.trim().split(",");
                      //print("loginCode: $loginCode");
                      if (loginCode.length < 3) {
                        // ignore: use_build_context_synchronously
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.red,
                                title: const Text(
                                  'Atencion',
                                  style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 245, 248, 245)),
                                ),
                                content: const Text(
                                  "No has introducidos los tres codígos",
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
                            });
                        return;
                      }
                      //return;
                      if (loginCode.length == 3) {
                        result = await loginRepository.login(loginCode[0].trim(), loginCode[1].trim(), loginCode[2].trim());

                        final data = result;
                        final statusLogin = result.status;
                        //print("${data?.status}, ${data?.idcliente}, ${data?.body}");

                        if (statusLogin) {
                          //establecemos en valor de idcliente para usarlo
                          PickingVars.COMPANYNAME = data.companyName;
                          PickingVars.codeI = loginCode[0].trim().toUpperCase();
                          PickingVars.codeII = loginCode[1].trim().toUpperCase();
                          PickingVars.codeIII = loginCode[2].trim().toUpperCase();
                          PickingVars.IDCLIENTE = data.idcliente!;
                          PickingVars.USERSKU = loginCode[0].trim().toUpperCase();
                          PickingVars.USERNAME = data.userName;
                          PickingVars.CAJASNAME = data.companyName;
                          setLogin(loginCode[0].trim().toUpperCase(), loginCode[1].trim().toUpperCase(), loginCode[2].trim().toUpperCase(), data.idcliente!,
                              data.companyName, data.userName);

                          //ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PickingListPage(idcliente: result.idcliente ?? 0)),
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: "Codigos login no validos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 15,
                              textColor: Colors.white, //
                              fontSize: 16.0);
                        }
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
