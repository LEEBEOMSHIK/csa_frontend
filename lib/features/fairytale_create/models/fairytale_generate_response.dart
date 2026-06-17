import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';

class FairytaleGenerateResponse {
  final int id;
  final String title;
  final String language;
  final String voiceType;
  final List<FairytalePageResponse> pages;

  const FairytaleGenerateResponse({
    required this.id,
    required this.title,
    this.language = 'ko',
    this.voiceType = 'dad',
    required this.pages,
  });

  factory FairytaleGenerateResponse.fromJson(Map<String, dynamic> json) {
    return FairytaleGenerateResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      language: json['language'] as String? ?? 'ko',
      voiceType: json['voiceType'] as String? ?? 'dad',
      pages: (json['pages'] as List<dynamic>)
          .map((p) => FairytalePageResponse.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 오프라인 저장본(Hive)으로부터 재생용 응답을 구성한다.
  /// 이미지/오디오는 로컬 파일 경로를 사용한다.
  factory FairytaleGenerateResponse.fromOfflineSlide(
    OfflineSlideEntry entry, {
    required String language,
    required String voiceType,
  }) {
    final voiceKey = '${voiceType}_$language';
    return FairytaleGenerateResponse(
      id: int.tryParse(entry.fairytaleId) ?? 0,
      title: entry.title,
      language: language,
      voiceType: voiceType,
      pages: entry.pages
          .map(
            (p) => FairytalePageResponse(
              pageIndex: p.pageIndex,
              text: p.text,
              localImagePath:
                  p.localImagePath.isNotEmpty ? p.localImagePath : null,
              localAudioPath: p.localAudioPaths[voiceKey],
            ),
          )
          .toList(),
    );
  }
}

class FairytalePageResponse {
  final int pageIndex;
  final String text;
  final String? imageUrl;
  final String? audioUrl;

  /// 오프라인 저장 시 채워지는 로컬 파일 경로. 네트워크 응답에서는 null.
  final String? localImagePath;
  final String? localAudioPath;

  const FairytalePageResponse({
    required this.pageIndex,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.localImagePath,
    this.localAudioPath,
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
