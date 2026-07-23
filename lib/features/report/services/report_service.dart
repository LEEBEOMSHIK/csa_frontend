import 'package:csa_frontend/shared/services/api_client.dart';

/// 일반 인증 유저가 호출하는 신고 등록 서비스. admin 권한이 필요 없다.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  /// [targetType]은 "CONTENT" | "USER".
  Future<void> createReport({
    required String targetType,
    required int targetId,
    required String reason,
    String? detail,
  }) async {
    await ApiClient.instance.post(
      '/reports',
      data: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'detail': detail,
      },
    );
  }
}
