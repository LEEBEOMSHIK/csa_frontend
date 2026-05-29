import 'package:csa_frontend/features/my/models/my_fairytale.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class MyFairytaleService {
  MyFairytaleService._();
  static final MyFairytaleService instance = MyFairytaleService._();

  Future<List<MyFairytale>> fetchMyFairytales() async {
    final data = await ApiClient.instance.get('/fairytale/my');
    return (data as List<dynamic>)
        .map((e) => MyFairytale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 공유 토글 → 변경된 공유 상태(true=공유됨)를 반환
  Future<bool> toggleShare(int id) async {
    final data = await ApiClient.instance.post('/fairytale/$id/share');
    return (data as Map<String, dynamic>)['shared'] as bool;
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/fairytale/$id');
  }
}
