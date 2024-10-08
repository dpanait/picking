class Language {
  late int languagesId;
  late String language;
  Language({required this.languagesId, required this.language});

  Language.fromJson(Map<String, dynamic> json) {
    languagesId = int.parse(json['languages_id']);
    language = json['name'];
  }
}

class LanguagesResponse {
  late bool status;
  late List<Language> languages;
  LanguagesResponse({required this.status, required this.languages});

  LanguagesResponse.fromJson(Map<String, dynamic> json) {
    languages = <Language>[];
    json['languages'].forEach((e) {
      languages.add(Language.fromJson(e));
    });

    status = json['status'];
  }
}
