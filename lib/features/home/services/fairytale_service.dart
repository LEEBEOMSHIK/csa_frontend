import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/models/fairytale_detail.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

abstract class CatalogService {
  Future<List<FairytaleItem>> getFairytales({String? category, String? sort});
  Future<List<FairytaleCategory>> getCategories();
}

class FairytaleService implements CatalogService {
  FairytaleService._();
  static final FairytaleService instance = FairytaleService._();

  @override
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

  @override
  Future<List<FairytaleItem>> getFairytales({
    String? category,
    String? sort,
  }) async {
    final params = <String, dynamic>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    final data = await ApiClient.instance.get('/fairytale/list', params: params);
    return (data as List<dynamic>)
        .map((e) => FairytaleItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FairytaleDetailData> getDetail(int id) async {
    final data = await ApiClient.instance.get('/fairytale/$id/detail');
    return FairytaleDetailData.fromJson(data as Map<String, dynamic>);
  }
}
