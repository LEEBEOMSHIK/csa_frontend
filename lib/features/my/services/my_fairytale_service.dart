import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/my/models/my_fairytale.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

abstract class MyFairytaleApiClient {
  Future<dynamic> get(String path);
  Future<dynamic> post(String path);
  Future<dynamic> delete(String path);
}

class _DefaultMyFairytaleApiClient implements MyFairytaleApiClient {
  @override
  Future<dynamic> get(String path) => ApiClient.instance.get(path);

  @override
  Future<dynamic> post(String path) => ApiClient.instance.post(path);

  @override
  Future<dynamic> delete(String path) => ApiClient.instance.delete(path);
}

class MyFairytaleService {
  final MyFairytaleApiClient _api;

  MyFairytaleService({MyFairytaleApiClient? api})
    : _api = api ?? _DefaultMyFairytaleApiClient();

  static final MyFairytaleService instance = MyFairytaleService();

  Future<List<MyFairytale>> fetchMyFairytales() async {
    final data = await _api.get('/fairytale/my');
    return (data as List<dynamic>)
        .map((e) => MyFairytale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FairytaleGenerateResponse> fetchSlides(int id) async {
    final data = await _api.get('/fairytale/$id/slides');
    return FairytaleGenerateResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 공유 토글 → 변경된 공유 상태(true=공유됨)를 반환
  Future<bool> toggleShare(int id) async {
    final data = await _api.post('/fairytale/$id/share');
    return (data as Map<String, dynamic>)['shared'] as bool;
  }

  Future<void> delete(int id) async {
    await _api.delete('/fairytale/$id');
  }
}
