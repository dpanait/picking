import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:piking/injection_container.dart';
import 'package:piking/feature/stock/data/remote/model/location_model.dart';
import 'package:piking/feature/stock/domain/entities/location_entity.dart';
import 'package:piking/feature/stock/domain/entities/location_origin_entity.dart';
import 'package:piking/feature/stock/domain/entities/products_location_entity.dart';
import 'package:piking/feature/stock/domain/model/selected_location_model.dart';
import 'package:piking/feature/stock/domain/provider/products_location_provider.dart';
import 'package:piking/feature/stock/domain/provider/search_location_provider.dart';
import 'package:provider/provider.dart';

import 'mock/test_moch_product_location.dart';
import 'mock/test_moch_search_location_provider.dart';
import 'mock/test_popup_fun.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await initializeDependencies();
  late MockProductsLocationProvider mockProductsLocationProvider;
  late MockSearchLocationProvider mockSearchLocationProvider;
  setUp(() {
    mockProductsLocationProvider = MockProductsLocationProvider();
    mockSearchLocationProvider = MockSearchLocationProvider();
  });
  test("prueba test", () {
    String query = "P1-A2";
    int cajasId = 311;
    int productsId = 1234;
    when(mockSearchLocationProvider.searchLocation(query, cajasId, productsId))
        .thenAnswer((_) async => Future.value());
    expect(mockProductsLocationProvider.locationsReponse, LocationResponseEntity.empty());
    when(mockProductsLocationProvider.locationEan("8435579770467", 0))
      .thenAnswer((realInvocation) async => Future.value());

  });
  testWidgets('Test popUpLocationChange shows correctly', (WidgetTester tester) async {
   
    // Preparar el producto de prueba
    ProductsLocationEntity item = const ProductsLocationEntity(
      productsId: 1234,
      productsSku: "1234",
      quantity: 4,
      cajasId: 311,
      productsName: "Producto prueeba 1",
      productsQuantity: 30,
      located: 0,
      locationsFavorite: '',
      reference: 'LM564',
      locationsId: 1,
      cajasAlias: 0,
      cajasName: 'Principal',
      quantityMax: 0,
      image: '', multiEan: false
    );

    List<LocationEntity> locationOld = [
      LocationEntity(
        locationsId: 1, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '1',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
      LocationEntity(
        locationsId: 2, 
        cajasId: 311,
        IDCLIENTE: 192,
        A: '1',
        P: '2',
        H: '3',
        R: '2',
        Z: '',
        locationsSku: 'A1', 
        txtLocation: "P1-A1-H4",
        description: 'First Location',
        sortOrder: 1,
        status: 1),
    ];
    SelectedLocation selectedLocation = SelectedLocation(1, 311, 1234, 2, 10);
    String query = "P1-A2";
    int cajasId = 311;
    int productsId = 1234;
    // Simula el comportamiento del provider
    when(mockSearchLocationProvider.searchLocation(query, cajasId, productsId))
        .thenAnswer((_) async => Future.value());
    // when(mockSearchLocationProvider.searchLocation(query, cajasId, productsId))
    // .thenReturn(Future<void>.value());
    //when(mockSearchLocationProvider.results).thenReturn(locationOld);
    // when(mockSearchLocationProvider.results)
    //     .thenAnswer((_) => locationOld);

    // Construye el widget para el test
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductsLocationProvider>(
            create: (_) => mockProductsLocationProvider,
          ),
          ChangeNotifierProvider<SearchLocationProvider>(
            create: (_) => mockSearchLocationProvider,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await popUpLocationChange(context, item, locationOld);
                },
                child: Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Interactuar con el botón para abrir el diálogo
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();  // Espera a que todos los widgets se dibujen

    // Verifica que el título del diálogo aparece
    //expect(find.text('Cambiar de ubicación'), findsOneWidget);

    // Verifica que el campo SKU del producto está visible
    expect(find.text('1234'), findsOneWidget);

    // Simula escribir en el campo de búsqueda
    await tester.enterText(find.byType(TextField).first, 'A');
    verify(mockSearchLocationProvider.searchLocation('A', item.cajasId!, item.productsId!)).called(1);

    // Verifica que las ubicaciones anteriores se muestran
    expect(find.text('First Location'), findsOneWidget);
    expect(find.text('Second Location'), findsOneWidget);

    // Simula hacer clic en el botón "MOVER"
    await tester.tap(find.text('MOVER'));
    await tester.pumpAndSettle();  // Espera a que el diálogo desaparezca

    // Verifica que el método `changeLocation` se llamó
    verify(mockProductsLocationProvider.changeLocation(selectedLocation)).called(1);

  });
}