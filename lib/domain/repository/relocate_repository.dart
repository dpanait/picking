import 'package:piking/domain/model/relocate.dart';
import 'package:piking/domain/response/relocate_response.dart';

abstract class RelocateRepository {
  Future<RelocateResponse> saveRelocate(int idCliente, Relocate relocate);
}
