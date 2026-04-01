class FairytaleGenerateResponse {
  final int id;
  final String title;
  final List<FairytalePageResponse> pages;

  const FairytaleGenerateResponse({
    required this.id,
    required this.title,
    required this.pages,
  });

  factory FairytaleGenerateResponse.fromJson(Map<String, dynamic> json) {
    return FairytaleGenerateResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((p) => FairytalePageResponse.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FairytalePageResponse {
  final int pageIndex;
  final String text;
  final String? imageUrl;
  final String? audioUrl;

  const FairytalePageResponse({
    required this.pageIndex,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });

  factory FairytalePageResponse.fromJson(Map<String, dynamic> json) {
    return FairytalePageResponse(
      pageIndex: json['pageIndex'] as int,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}
