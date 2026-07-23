import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/features/admin/models/admin_report.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class AdminReportService {
  AdminReportService._();
  static final AdminReportService instance = AdminReportService._();

  Future<AdminPageResponse<AdminReport>> fetchReports({
    String status = 'PENDING',
    String? targetType,
    int page = 0,
    int size = 20,
  }) async {
    final data = await ApiClient.instance.get(
      '/admin/reports',
      params: {
        'status': status,
        if (targetType != null && targetType.isNotEmpty)
          'targetType': targetType,
        'page': page,
        'size': size,
      },
    );
    return AdminPageResponse.fromJson(
      data as Map<String, dynamic>,
      AdminReport.fromJson,
    );
  }

  Future<AdminReport> fetchReport(int id) async {
    final data = await ApiClient.instance.get('/admin/reports/$id');
    return AdminReport.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminReport> resolve(
    int id, {
    required String status,
    String? adminNote,
  }) async {
    final data = await ApiClient.instance.patch(
      '/admin/reports/$id',
      data: {'status': status, 'adminNote': adminNote},
    );
    return AdminReport.fromJson(data as Map<String, dynamic>);
  }
}
