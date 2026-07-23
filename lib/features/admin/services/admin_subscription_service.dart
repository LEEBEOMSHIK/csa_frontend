import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/features/admin/models/admin_subscription.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

/// 구독 정보는 조회 전용이다. 스토어 영수증 검증으로만 갱신되는 정책이라
/// 관리자가 수동으로 변경하는 엔드포인트는 존재하지 않는다.
class AdminSubscriptionService {
  AdminSubscriptionService._();
  static final AdminSubscriptionService instance =
      AdminSubscriptionService._();

  Future<AdminPageResponse<AdminSubscription>> fetchSubscriptions({
    String? q,
    String? platform,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final data = await ApiClient.instance.get(
      '/admin/subscriptions',
      params: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (platform != null && platform.isNotEmpty) 'platform': platform,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'size': size,
      },
    );
    return AdminPageResponse.fromJson(
      data as Map<String, dynamic>,
      AdminSubscription.fromJson,
    );
  }

  Future<AdminSubscription> fetchSubscription(int id) async {
    final data = await ApiClient.instance.get('/admin/subscriptions/$id');
    return AdminSubscription.fromJson(data as Map<String, dynamic>);
  }
}
