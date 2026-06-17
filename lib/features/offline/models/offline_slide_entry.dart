import 'package:hive_flutter/hive_flutter.dart';

/// offline_slide_box 에 저장되는 슬라이드 동화 오프라인 본문 데이터.
/// 이미지/오디오 바이너리는 파일시스템에 저장하고, 여기에는 로컬 경로만 보관한다.
class OfflineSlideEntry {
  final String fairytaleId;
  final String title;
  final String thumbnailLocalPath;
  final List<OfflineSlidePage> pages;
  final DateTime downloadedAt;

  const OfflineSlideEntry({
    required this.fairytaleId,
    required this.title,
    required this.thumbnailLocalPath,
    required this.pages,
    required this.downloadedAt,
  });
}

class OfflineSlidePage {
  final int pageIndex;
  final String text;
  final String localImagePath;

  /// 'dad_ko' → '/.../page_1_dad_ko.mp3'
  final Map<String, String> localAudioPaths;

  const OfflineSlidePage({
    required this.pageIndex,
    required this.text,
    required this.localImagePath,
    required this.localAudioPaths,
  });
}

class OfflineSlideEntryAdapter extends TypeAdapter<OfflineSlideEntry> {
  @override
  final int typeId = 20;

  @override
  OfflineSlideEntry read(BinaryReader reader) {
    final fairytaleId = reader.readString();
    final title = reader.readString();
    final thumbnailLocalPath = reader.readString();
    final pageCount = reader.readInt();
    final pages = <OfflineSlidePage>[
      for (var i = 0; i < pageCount; i++) _readPage(reader),
    ];
    final downloadedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return OfflineSlideEntry(
      fairytaleId: fairytaleId,
      title: title,
      thumbnailLocalPath: thumbnailLocalPath,
      pages: pages,
      downloadedAt: downloadedAt,
    );
  }

  OfflineSlidePage _readPage(BinaryReader reader) {
    final pageIndex = reader.readInt();
    final text = reader.readString();
    final localImagePath = reader.readString();
    final audioCount = reader.readInt();
    final audioPaths = <String, String>{};
    for (var i = 0; i < audioCount; i++) {
      final key = reader.readString();
      final value = reader.readString();
      audioPaths[key] = value;
    }
    return OfflineSlidePage(
      pageIndex: pageIndex,
      text: text,
      localImagePath: localImagePath,
      localAudioPaths: audioPaths,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineSlideEntry obj) {
    writer.writeString(obj.fairytaleId);
    writer.writeString(obj.title);
    writer.writeString(obj.thumbnailLocalPath);
    writer.writeInt(obj.pages.length);
    for (final page in obj.pages) {
      writer.writeInt(page.pageIndex);
      writer.writeString(page.text);
      writer.writeString(page.localImagePath);
      writer.writeInt(page.localAudioPaths.length);
      page.localAudioPaths.forEach((key, value) {
        writer.writeString(key);
        writer.writeString(value);
      });
    }
    writer.writeInt(obj.downloadedAt.millisecondsSinceEpoch);
  }
}
