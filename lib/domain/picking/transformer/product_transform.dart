import 'package:piking/data/local/entity/product_entity.dart';
import 'package:piking/domain/model/orders_products.dart';

// productBodyTransformToProduct(BodyProducts productBody, int id) {
//   var product = ProductCompanion(
//       id: const drift.Value(0),
//       ordersId: drift.Value(productBody.ordersId),
//       ordersSku: drift.Value(productBody.ordersSku),
//       ordersProductsId: drift.Value(productBody.ordersProductsId.toString()),
//       productsId: drift.Value(productBody.productsId),
//       productsSku: drift.Value(productBody.productsSku),
//       barcode: drift.Value(productBody.barcode),
//       referencia: drift.Value(productBody.referencia),
//       productsName: drift.Value(productBody.productsName),
//       productsQuantity: drift.Value(productBody.productsQuantity),
//       image: drift.Value(productBody.image),
//       picking: drift.Value(productBody.piking),
//       location: drift.Value(productBody.location),
//       quantityProcessed: drift.Value(productBody.quantityProcessed),
//       serieLote:
//           drift.Value(productBody.serieLote)); //productBody.serieLote ?? null;

//   return product;
// }

// productTransformToBodyProduct(ProductData product) {
//   print("productTransformToBodyProduct: ${jsonEncode(product)}");
//   var productBody = BodyProducts(
//       ordersId: product.ordersId,
//       ordersSku: product.ordersSku,
//       ordersProductsId: product.ordersProductsId,
//       productsId: product.productsId.toString(),
//       productsSku: product.productsSku,
//       barcode: product.barcode,
//       referencia: product.referencia ?? "",
//       productsName: product.productsName ?? "",
//       productsQuantity: product.productsQuantity,
//       image: product.image ?? "",
//       piking: product.picking.toString(),
//       location: product.location ?? "",
//       quantityProcessed: product.quantityProcessed.toString(),
//       serieLote: product.serieLote.toString());

//   return productBody;
// }

productDtoToBodyProduct(Product product) {
  //print("productDtoToBodyProduct: ${jsonEncode(product)}");
  var productBody = OrdersProducts(
      ordersId: product.ordersId,
      ordersSku: product.ordersSku,
      ordersProductsId: product.ordersProductsId,
      productsId: product.productsId.toString(),
      productsSku: product.productsSku,
      barcode: product.barcode,
      referencia: product.referencia,
      productsName: product.productsName,
      productsQuantity: product.productsQuantity,
      image: product.image,
      piking: product.picking.toString(),
      location: product.location,
      locationId: product.locationId.toString(),
      quantityProcessed: product.quantityProcessed.toString(),
      serieLote: product.serieLote.toString(),
      udsPack: product.udsPack.toString(),
      udsBox: product.udsBox.toString(),
      pickingCode: product.pickingCode.toString(),
      stock: product.stock);

  return productBody;
}
