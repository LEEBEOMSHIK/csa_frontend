import 'package:hive_flutter/hive_flutter.dart';

enum DownloadStatus { downloading, completed, failed }

/// offline_meta_box 에 저장되는 다운로드 상태/용량/TTL 메타데이터.
class OfflineMetaEntry {
  final String fairytaleId;
  final String format; // 'slide' (영상은 후속 단계)
  final int totalSizeBytes;
  final DateTime downloadedAt;
  final DateTime? expiresAt; // TTL (null = 무기한 — 정책상 사용하지 않음)
  final DownloadStatus status;

  const OfflineMetaEntry({
    required this.fairytaleId,
    required this.format,
    required this.totalSizeBytes,
    required this.downloadedAt,
    this.expiresAt,
    required this.status,
  });

  bool get isCompleted => status == DownloadStatus.completed;

  bool isExpired(DateTime now) =>
      expiresAt != null && now.isAfter(expiresAt!);

  OfflineMetaEntry copyWith({
    int? totalSizeBytes,
    DownloadStatus? status,
    DateTime? downloadedAt,
    DateTime? expiresAt,
  }) {
    return OfflineMetaEntry(
      fairytaleId: fairytaleId,
      format: format,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }
}

class OfflineMetaEntryAdapter extends TypeAdapter<OfflineMetaEntry> {
  @override
  final int typeId = 21;

  @override
  OfflineMetaEntry read(BinaryReader reader) {
    final fairytaleId = reader.readString();
    final format = reader.readString();
    final totalSizeBytes = reader.readInt();
    final downloadedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasExpiry = reader.readBool();
    final expiresAt = hasExpiry
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    final statusIndex = reader.readInt();
    return OfflineMetaEntry(
      fairytaleId: fairytaleId,
      format: format,
      totalSizeBytes: totalSizeBytes,
      downloadedAt: downloadedAt,
      expiresAt: expiresAt,
      status: DownloadStatus.values[statusIndex],
    );
  }

  @override
  void write(BinaryWriter writer, OfflineMetaEntry obj) {
    writer.writeString(obj.fairytaleId);
    writer.writeString(obj.format);
    writer.writeInt(obj.totalSizeBytes);
    writer.writeInt(obj.downloadedAt.millisecondsSinceEpoch);
    writer.writeBool(obj.expiresAt != null);
    if (obj.expiresAt != null) {
      writer.writeInt(obj.expiresAt!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.status.index);
  }
}
