import 'package:csa_frontend/features/admin/models/admin_fairytale.dart';
import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class AdminFairytaleService {
  AdminFairytaleService._();
  static final AdminFairytaleService instance = AdminFairytaleService._();

  Future<AdminPageResponse<AdminFairytale>> fetchFairytales({
    String? q,
    String? status,
    String? shared,
    int page = 0,
    int size = 20,
  }) async {
    final data = await ApiClient.instance.get(
      '/admin/fairytales',
      params: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (status != null && status.isNotEmpty) 'status': status,
        if (shared != null && shared.isNotEmpty) 'shared': shared,
        'page': page,
        'size': size,
      },
    );
    return AdminPageResponse.fromJson(
      data as Map<String, dynamic>,
      AdminFairytale.fromJson,
    );
  }

  Future<AdminFairytale> fetchFairytale(int id) async {
    final data = await ApiClient.instance.get('/admin/fairytales/$id');
    return AdminFairytale.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminFairytale> unshare(int id) async {
    final data = await ApiClient.instance.patch(
      '/admin/fairytales/$id/unshare',
    );
    return AdminFairytale.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteFairytale(int id) async {
    await ApiClient.instance.delete('/admin/fairytales/$id');
  }
}
