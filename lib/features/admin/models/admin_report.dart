/// 백엔드 `AdminReportDto` 모델.
class AdminReport {
  final int id;
  final String? reporterEmail;
  final String targetType;
  final int targetId;
  final String reason;
  final String? detail;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const AdminReport({
    required this.id,
    this.reporterEmail,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.detail,
    required this.status,
    this.adminNote,
    this.createdAt,
    this.resolvedAt,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    return AdminReport(
      id: json['id'] as int,
      reporterEmail: json['reporterEmail'] as String?,
      targetType: json['targetType'] as String? ?? '',
      targetId: json['targetId'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      detail: json['detail'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      adminNote: json['adminNote'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
    );
  }
}
