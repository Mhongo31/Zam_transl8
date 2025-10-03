class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final DateTime joinDate;
  final int streakDays;
  final int totalTranslations;
  final List<String> favoriteLanguages;
  final Map<String, int> languageProgress;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage = '',
    required this.joinDate,
    this.streakDays = 0,
    this.totalTranslations = 0,
    this.favoriteLanguages = const [],
    this.languageProgress = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'] ?? '',
      joinDate: DateTime.parse(json['joinDate']),
      streakDays: json['streakDays'] ?? 0,
      totalTranslations: json['totalTranslations'] ?? 0,
      favoriteLanguages: List<String>.from(json['favoriteLanguages'] ?? []),
      languageProgress: Map<String, int>.from(json['languageProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'joinDate': joinDate.toIso8601String(),
      'streakDays': streakDays,
      'totalTranslations': totalTranslations,
      'favoriteLanguages': favoriteLanguages,
      'languageProgress': languageProgress,
    };
  }
}
