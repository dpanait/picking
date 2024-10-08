import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable{
  late int locationsId;
  late int cajasId;
  late int IDCLIENTE;
  late String description;
  late String P;
  late String R;
  late String A;
  late String H;
  late String Z;
  late int sortOrder;
  late int status;
  late String? locationsSku;
  late String? txtLocation = "";

  LocationEntity({
    required this.locationsId,
    required this.cajasId,
    required this.IDCLIENTE,
    required this.description,
    required this.P,
    required this.R,
    required this.A,
    required this.H,
    required this.Z,
    required this.sortOrder,
    required this.status,
    this.locationsSku,
    this.txtLocation
  });
  static empty() {
    return LocationEntity(
        locationsId:  0,
        cajasId: 0,
        IDCLIENTE: 0,
        description: '',
        P: '',
        R: '',
        A: '',
        H: '',
        Z: '',
        sortOrder: 0,
        status: 0
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      locationsId,
      cajasId,
      IDCLIENTE,
      description,
      P,
      R,
      A,
      H,
      Z,
      sortOrder,
      status
    ];
  }

}