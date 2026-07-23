/// 백엔드 `AdminSubscriptionDto` 모델. 조회 전용 — 수정 필드 없음.
class AdminSubscription {
  final int id;
  final String? userEmail;
  final String platform;
  final String productId;
  final String status;
  final String environment;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;

  const AdminSubscription({
    required this.id,
    this.userEmail,
    required this.platform,
    required this.productId,
    required this.status,
    required this.environment,
    this.currentPeriodEnd,
    required this.autoRenew,
  });

  factory AdminSubscription.fromJson(Map<String, dynamic> json) {
    return AdminSubscription(
      id: json['id'] as int,
      userEmail: json['userEmail'] as String?,
      platform: json['platform'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      environment: json['environment'] as String? ?? '',
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.tryParse(json['currentPeriodEnd'] as String)
          : null,
      autoRenew: json['autoRenew'] as bool? ?? false,
    );
  }
}
