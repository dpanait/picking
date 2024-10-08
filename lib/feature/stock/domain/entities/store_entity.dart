import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable{
  int? cajasId;
  String? cajasName;
  String? cajasNameY;
  StoreEntity({this.cajasId, this.cajasName, this.cajasNameY});

 static empty(){
  return StoreEntity(cajasId: 0, cajasName: "", cajasNameY: "");
 }
  @override
  // TODO: implement props
  List<Object?> get props{
    return [
      cajasId,
      cajasName,
      cajasNameY
    ];
  }
  
}