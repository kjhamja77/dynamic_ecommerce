import 'package:equatable/equatable.dart';

enum LanguageCode {
  english('en'),
  arabic('ar');

  const LanguageCode(this.code);
  final String code;
}

class Language extends Equatable {
  final LanguageCode code;
  final String name;
  final String nativeName;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<Language> supportedLanguages = [
    Language(
      code: LanguageCode.english,
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    Language(
      code: LanguageCode.arabic,
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇮🇶',
    ),
  ];

  static Language get defaultLanguage => supportedLanguages.first;

  @override
  List<Object?> get props => [code, name, nativeName, flag];
}
