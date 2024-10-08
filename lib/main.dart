import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piking/data/remote/model/store_response.dart';
import 'package:piking/domain/picking/db/data_base_picking_connexion.dart';
import 'package:piking/domain/provider/process_picking_provider.dart';
import 'package:piking/domain/provider/products_location_provider.dart';
import 'package:piking/domain/provider/test_provider.dart';
import 'package:piking/domain/repository/login_repository.dart';
import 'package:piking/domain/repository/store_repository.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/presentation/login_page.dart';
import 'package:piking/presentation/picking_list_page.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:piking/vars.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  /*runApp(Provider(
    create: (contet) => Database(),
    child: const MyApp(),
  ));*/
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  PickingDatabaseConnection();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<TestProvider>(create: (_) => TestProvider()),
    ChangeNotifierProvider<ProcessPickingProvider>(create: (_) => ProcessPickingProvider()),
    ChangeNotifierProvider<ProductsLocationProviderOld>(create: (_) => ProductsLocationProviderOld()),
    ChangeNotifierProvider<ProductsLocationProvider>(create: (_) => ProductsLocationProvider()),
    ChangeNotifierProvider<SearchLocationProvider>(create: (_) => SearchLocationProvider()),
  ], child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppSTate();
}

class _MyAppSTate extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var code1 = "";
  var code2 = "";
  var code3 = "";
  var idcliente = 0;
  var storeRepository = di.get<StoreRepository>();
  var loginRepository = di.get<LoginRepository>();
  StoreResponse storeResponse = StoreResponse(status: false);
  List<Store> store = [];

  // This widget is the root of your application.
  getLogin() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      code1 = prefs.getString("code1") ?? "";
      code2 = prefs.getString("code2") ?? "";
      code3 = prefs.getString("code3") ?? "";
      idcliente = prefs.getInt("IDCLIENTE") ?? 0;
      PickingVars.IDCLIENTE = prefs.getInt("IDCLIENTE") ?? 0;
      PickingVars.USERSKU = prefs.getString("code1") ?? "";
      PickingVars.USERNAME = prefs.getString("userName") ?? "";
    });
  }

  getAllStore() async {
    storeResponse = await storeRepository.getAllStore(idcliente);
    setState(() {
      storeResponse.body?.forEach((element) {
        store.add(Store.fromJson(element.toJson()));
      });
    });
  }

  @override
  initState() {
    super.initState();
    loginRepository.getVersion();
    getLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Picking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent), //Colors.deepPurple
          useMaterial3: false,
        ),
        home: code1 != "" && code2 != "" && code3 != ""
            ? PickingListPage(idcliente: idcliente)
            : const LoginPage() //const MyHomePage(title: 'Flutter Demo Home Page'),
        );
        
  }
}


/*class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}*/
