class FairytaleGenerateRequest {
  final List<String> settings;
  final String genre;
  final String theme;
  final int chapterCount;
  final bool useCharacter;
  final String voiceType;
  final String language;
  final String format; // 'slide' | 'video'

  const FairytaleGenerateRequest({
    required this.settings,
    required this.genre,
    required this.theme,
    required this.chapterCount,
    required this.useCharacter,
    required this.voiceType,
    required this.language,
    required this.format,
  });

  Map<String, dynamic> toJson() => {
    'settings': settings,
    'genre': genre,
    'theme': theme,
    'chapterCount': chapterCount,
    'useCharacter': useCharacter,
    'voiceType': voiceType,
    'language': language,
    'format': format,
  };

  static const List<String> settingKeys = [
    'adventure', 'family', 'fantasy', 'friendship',
    'animal', 'sea', 'space', 'magic',
    'forest', 'kingdom', 'school', 'city',
  ];

  static const List<String> genreKeys = [
    'classic', 'folklore', 'comedy', 'mystery', 'scifi',
    'musical', 'quiz', 'daily', 'dream', 'horror',
  ];

  static const List<String> themeKeys = [
    'moral', 'friendship', 'family_love', 'courage', 'growth', 'sharing',
    'self_expression', 'environment', 'gratitude', 'problem_solving',
    'curiosity', 'forgiveness',
  ];

  static const List<int> chapterCounts = [3, 5, 7];

  static const List<String> voiceTypeKeys = ['dad', 'mom', 'grandma', 'grandpa'];
}
