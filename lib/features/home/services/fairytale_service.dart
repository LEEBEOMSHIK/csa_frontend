import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/models/fairytale_detail.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class FairytaleService {
  FairytaleService._();
  static final FairytaleService instance = FairytaleService._();

  Future<List<FairytaleCategory>> getCategories() async {
    final data = await ApiClient.instance.get('/fairytale/categories');
    return (data as List<dynamic>)
        .map((e) => FairytaleCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HomePageData> getHomePage({String? categoryKey, String? lang}) async {
    final params = <String, dynamic>{};
    if (categoryKey != null) params['category'] = categoryKey;
    if (lang != null) params['lang'] = lang;
    final data = await ApiClient.instance.get('/fairytale/home', params: params);
    return HomePageData.fromJson(data as Map<String, dynamic>);
  }

  Future<FairytaleDetailData> getDetail(int id) async {
    final data = await ApiClient.instance.get('/fairytale/$id/detail');
    return FairytaleDetailData.fromJson(data as Map<String, dynamic>);
  }
}
