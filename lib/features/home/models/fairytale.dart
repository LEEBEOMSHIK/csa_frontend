class FairytaleItem {
  final int id;
  final String title;
  final String? titleJa;
  final String? description;
  final String? descriptionJa;
  final double? rating;
  final String? colorHex;
  final String? themeTag;
  final List<String> categories;

  const FairytaleItem({
    required this.id,
    required this.title,
    this.titleJa,
    this.description,
    this.descriptionJa,
    this.rating,
    this.colorHex,
    this.themeTag,
    required this.categories,
  });

  factory FairytaleItem.fromJson(Map<String, dynamic> json) {
    return FairytaleItem(
      id: json['id'] as int,
      title: json['title'] as String,
      titleJa: json['titleJa'] as String?,
      description: json['description'] as String?,
      descriptionJa: json['descriptionJa'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      colorHex: json['colorHex'] as String?,
      themeTag: json['themeTag'] as String?,
      categories: (json['categories'] as List<dynamic>).cast<String>(),
    );
  }

  String titleFor(String lang) =>
      lang == 'ja' && titleJa != null ? titleJa! : title;

  String? descriptionFor(String lang) =>
      lang == 'ja' && descriptionJa != null ? descriptionJa : description;
}

class HomePageData {
  final List<FairytaleItem> themes;
  final List<FairytaleItem> newItems;
  final List<FairytaleItem> recommended;

  const HomePageData({
    required this.themes,
    required this.newItems,
    required this.recommended,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    return HomePageData(
      themes: (json['themes'] as List<dynamic>)
          .map((e) => FairytaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      newItems: (json['newItems'] as List<dynamic>)
          .map((e) => FairytaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommended: (json['recommended'] as List<dynamic>)
          .map((e) => FairytaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
