import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.code,
    required super.name,
    required super.nativeName,
    required super.flag,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: LanguageCode.values.firstWhere(
        (e) => e.code == json['code'],
        orElse: () => LanguageCode.english,
      ),
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      flag: json['flag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.code,
      'name': name,
      'nativeName': nativeName,
      'flag': flag,
    };
  }

  factory LanguageModel.fromLanguage(Language language) {
    return LanguageModel(
      code: language.code,
      name: language.name,
      nativeName: language.nativeName,
      flag: language.flag,
    );
  }
}
