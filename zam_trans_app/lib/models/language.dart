class Language {
  final String code;
  final String name;
  final String nativeName;
  final bool isFree;
  final bool isAvailable;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isFree,
    this.isAvailable = true,
  });

  static const List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English', nativeName: 'English', isFree: true),
    Language(code: 'lunda', name: 'Lunda', nativeName: 'Lunda', isFree: true),
    Language(code: 'bem', name: 'Bemba', nativeName: 'Ichibemba', isFree: true),
    Language(code: 'nya', name: 'Nyanja', nativeName: 'Chinyanja', isFree: false),
    Language(code: 'ton', name: 'Tonga', nativeName: 'Chitonga', isFree: false),
    Language(code: 'loz', name: 'Lozi', nativeName: 'Silozi', isFree: false),
    Language(code: 'kau', name: 'Kaonde', nativeName: 'Kikaonde', isFree: false),
  ];

  static Language getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
