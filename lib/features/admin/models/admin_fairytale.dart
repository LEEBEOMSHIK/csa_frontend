/// 백엔드 `AdminFairytaleDto` 모델. 목록/상세 모두 동일 구조.
class AdminFairytale {
  final int id;
  final String title;
  final String? ownerEmail;
  final String format;
  final String status;
  final String language;
  final bool shared;
  final int chapterCount;
  final DateTime? createdAt;

  const AdminFairytale({
    required this.id,
    required this.title,
    this.ownerEmail,
    required this.format,
    required this.status,
    required this.language,
    required this.shared,
    required this.chapterCount,
    this.createdAt,
  });

  factory AdminFairytale.fromJson(Map<String, dynamic> json) {
    return AdminFairytale(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String?,
      format: json['format'] as String? ?? '',
      status: json['status'] as String? ?? '',
      language: json['language'] as String? ?? 'ko',
      shared: json['shared'] as bool? ?? false,
      chapterCount: json['chapterCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
