class MyFairytale {
  final int id;
  final String title;
  final String format; // slide / video
  final String status; // GENERATING / COMPLETED / FAILED
  final String language;
  final bool shared;
  final String? thumbnailUrl;
  final int pageCount;
  final DateTime? createdAt;
  final int? ownerId;

  const MyFairytale({
    required this.id,
    required this.title,
    required this.format,
    required this.status,
    required this.language,
    required this.shared,
    this.thumbnailUrl,
    required this.pageCount,
    this.createdAt,
    this.ownerId,
  });

  bool get isCompleted => status == 'COMPLETED';

  /// 열람 가능 여부. 영상 합성이 실패해도 페이지가 남아 있으면 슬라이드로 열 수 있다.
  bool get isPlayable =>
      isCompleted || (format == 'video' && status == 'FAILED' && pageCount > 0);

  factory MyFairytale.fromJson(Map<String, dynamic> json) {
    return MyFairytale(
      id: json['id'] as int,
      title: json['title'] as String,
      format: json['format'] as String? ?? 'slide',
      status: json['status'] as String? ?? 'COMPLETED',
      language: json['language'] as String? ?? 'ko',
      shared: json['shared'] as bool? ?? false,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      pageCount: json['pageCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      ownerId: json['ownerId'] as int?,
    );
  }

  MyFairytale copyWith({bool? shared}) {
    return MyFairytale(
      id: id,
      title: title,
      format: format,
      status: status,
      language: language,
      shared: shared ?? this.shared,
      thumbnailUrl: thumbnailUrl,
      pageCount: pageCount,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}
