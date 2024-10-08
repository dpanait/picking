import 'package:flutter_test/flutter_test.dart';

void main() async {
  test("prueba test", () {
    int a = 7;
    int b = 4;
    int result =  a + b;
    expect(result, 12);
  });
}