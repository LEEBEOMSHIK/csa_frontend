class CuratedSlidesManifest {
  final int fairytaleId;
  final String contentVersion;
  final bool characterSupported;
  final String characterRenderMode;
  final List<CuratedSlidePage> pages;

  const CuratedSlidesManifest({
    required this.fairytaleId,
    required this.contentVersion,
    required this.characterSupported,
    required this.characterRenderMode,
    required this.pages,
  });

  factory CuratedSlidesManifest.fromJson(Map<String, dynamic> json) {
    return CuratedSlidesManifest(
      fairytaleId: json['fairytaleId'] as int,
      contentVersion: json['contentVersion'] as String,
      characterSupported: json['characterSupported'] as bool,
      characterRenderMode: json['characterRenderMode'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map(
            (page) => CuratedSlidePage.fromJson(page as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CuratedSlidePage {
  final int pageIndex;
  final String imageUrl;
  final CuratedLocalizedText text;
  final Map<String, Map<String, String>> audioUrls;
  final CharacterPlacement? characterPlacement;

  const CuratedSlidePage({
    required this.pageIndex,
    required this.imageUrl,
    required this.text,
    required this.audioUrls,
    this.characterPlacement,
  });

  factory CuratedSlidePage.fromJson(Map<String, dynamic> json) {
    final rawAudioUrls = json['audioUrls'] is Map
        ? (json['audioUrls'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    return CuratedSlidePage(
      pageIndex: json['pageIndex'] as int,
      imageUrl: json['imageUrl'] as String,
      text: CuratedLocalizedText.fromJson(json['text'] as Map<String, dynamic>),
      audioUrls: rawAudioUrls.map(
        (voiceType, locales) => MapEntry(
          voiceType,
          (locales as Map).cast<String, dynamic>().map(
            (locale, url) => MapEntry(locale, url as String),
          ),
        ),
      ),
      characterPlacement: CharacterPlacement.tryFromJson(
        json['characterPlacement'],
      ),
    );
  }

  String? audioUrlFor({required String voiceType, required String locale}) =>
      audioUrls[voiceType]?[locale];
}

class CuratedLocalizedText {
  final String ko;
  final String ja;

  const CuratedLocalizedText({required this.ko, required this.ja});

  factory CuratedLocalizedText.fromJson(Map<String, dynamic> json) {
    return CuratedLocalizedText(
      ko: json['ko'] as String,
      ja: json['ja'] as String,
    );
  }

  String forLocale(String locale) => locale == 'ja' ? ja : ko;
}

class CharacterPlacement {
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;
  final String pose;
  final bool flipX;

  const CharacterPlacement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
    required this.pose,
    required this.flipX,
  });

  static CharacterPlacement? tryFromJson(Object? value) {
    if (value is! Map) return null;
    final json = value.cast<String, dynamic>();
    final x = _asFiniteDouble(json['x']);
    final y = _asFiniteDouble(json['y']);
    final width = _asFiniteDouble(json['width']);
    final height = _asFiniteDouble(json['height']);
    final zIndex = json['zIndex'];
    final pose = json['pose'];
    final flipX = json['flipX'];
    if (x == null ||
        y == null ||
        width == null ||
        height == null ||
        zIndex is! num ||
        pose is! String ||
        flipX is! bool) {
      return null;
    }
    return CharacterPlacement(
      x: x,
      y: y,
      width: width,
      height: height,
      zIndex: zIndex.toInt(),
      pose: pose,
      flipX: flipX,
    );
  }

  static double? _asFiniteDouble(Object? value) {
    if (value is! num) return null;
    final result = value.toDouble();
    return result.isFinite ? result : null;
  }

  bool get isRenderableStandingOverlay =>
      pose == 'standing' &&
      x >= 0 &&
      y >= 0 &&
      width > 0 &&
      height > 0 &&
      x + width <= 1 &&
      y + height <= 1;
}
