import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/features/admin/models/admin_user.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class AdminUserService {
  AdminUserService._();
  static final AdminUserService instance = AdminUserService._();

  Future<AdminPageResponse<AdminUser>> fetchUsers({
    String? q,
    int page = 0,
    int size = 20,
  }) async {
    final data = await ApiClient.instance.get(
      '/admin/users',
      params: {
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'size': size,
      },
    );
    return AdminPageResponse.fromJson(
      data as Map<String, dynamic>,
      AdminUser.fromJson,
    );
  }

  Future<AdminUser> fetchUser(int id) async {
    final data = await ApiClient.instance.get('/admin/users/$id');
    return AdminUser.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminUser> updateStatus(int id, String status) async {
    final data = await ApiClient.instance.patch(
      '/admin/users/$id/status',
      data: {'status': status},
    );
    return AdminUser.fromJson(data as Map<String, dynamic>);
  }
}
