import 'package:floor/floor.dart';

@entity
class Product {
  @PrimaryKey()
  String ordersProductsId;
  String ordersId;
  String ordersSku;
  String productsId;
  String productsSku;
  String barcode;
  String referencia;
  String productsName;
  String productsQuantity;
  String image;
  String picking;
  String location;
  String locationId;
  String quantityProcessed;
  String serieLote;
  String udsPack;
  String udsBox;
  String pickingCode;
  String stock;

  Product(
      this.ordersProductsId,
      this.ordersId,
      this.ordersSku,
      this.productsId,
      this.productsSku,
      this.barcode,
      this.referencia,
      this.productsName,
      this.productsQuantity,
      this.image,
      this.picking,
      this.location,
      this.locationId,
      this.quantityProcessed,
      this.serieLote,
      this.udsPack,
      this.udsBox,
      this.pickingCode,
      this.stock);

  Map<String, dynamic> toJson(){
     final Map<String, dynamic> data = <String, dynamic>{};
      data['orders_products_id']= ordersProductsId;
      data['orders_id']= ordersId;
      data['orders_sku']= ordersSku;
      data['products_id']= productsId;
      data['products_sku']= productsSku;
      data['barcode']= barcode;
      data['referencia']= referencia;
      data['products_name']= productsName;
      data['products_quantity']= productsQuantity;
      data['image']= image;
      data['picking']= picking;
      data['location']= location;
      data['location_id']= locationId;
      data['quantity_processed']= quantityProcessed;
      data['serie_lote']= serieLote;
      data['uds_pack']= udsPack;
      data['uds_box']= udsBox;
      data['picking_code']= pickingCode;
      data['stock'] = stock;
    return data;
  }
}
