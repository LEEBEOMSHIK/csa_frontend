/// 백엔드 `AdminUserDto` / `AdminUserDetailDto` 공통 모델.
/// 두 DTO는 동일한 필드 구성이라 하나의 모델로 목록/상세를 모두 표현한다.
class AdminUser {
  final int id;
  final String email;
  final String? name;
  final String? provider;
  final String role;
  final String status;
  final DateTime? createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    this.name,
    this.provider,
    required this.role,
    required this.status,
    this.createdAt,
  });

  bool get isActive => status == 'ACTIVE';

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      provider: json['provider'] as String?,
      role: json['role'] as String? ?? 'USER',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
