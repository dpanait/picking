import 'package:piking/data/remote/utils/api.dart';
import 'package:piking/domain/response/languages_reponse.dart';
import 'package:piking/domain/repository/languages_repository.dart';

class LanguagesRepositoryImpl implements LanguagesRepository {
  late final Api _apiInstance;
  LanguagesRepositoryImpl(this._apiInstance);

  @override
  Future<List<Language>> getLanguages() async {
    LanguagesResponse response = await _apiInstance.getLanguages();
    //print("getLanguages: ${response.languages[0].language} - status: ${response.status}");
    return response.languages;
  }
}
