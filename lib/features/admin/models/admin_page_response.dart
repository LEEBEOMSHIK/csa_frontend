/// 백엔드 `PageResponse<T>` 공통 래퍼 파싱용 제네릭 모델.
/// `{content, page, size, totalElements, totalPages}` 형태를 그대로 따른다.
class AdminPageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const AdminPageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  bool get hasPrev => page > 0;
  bool get hasNext => page + 1 < totalPages;

  factory AdminPageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? const [];
    return AdminPageResponse(
      content: rawContent
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? rawContent.length,
      totalElements: json['totalElements'] as int? ?? rawContent.length,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
