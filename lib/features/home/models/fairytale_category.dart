class FairytaleCategory {
  final String categoryKey;
  final String nameKo;
  final String nameJa;
  final int count;

  const FairytaleCategory({
    required this.categoryKey,
    required this.nameKo,
    required this.nameJa,
    required this.count,
  });

  factory FairytaleCategory.fromJson(Map<String, dynamic> json) {
    return FairytaleCategory(
      categoryKey: json['categoryKey'] as String,
      nameKo: json['nameKo'] as String,
      nameJa: json['nameJa'] as String,
      count: json['count'] as int,
    );
  }
}
