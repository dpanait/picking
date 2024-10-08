import 'package:piking/domain/response/languages_reponse.dart';

abstract class LanguagesRepository {
  Future<List<Language>> getLanguages();
}
