import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class FavoriteService {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  Future<List<FairytaleItem>> fetchFavorites() async {
    final data = await ApiClient.instance.get('/favorites');
    return (data as List<dynamic>)
        .map((e) => FairytaleItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(int fairytaleId) async {
    await ApiClient.instance.post('/favorites/$fairytaleId');
  }

  Future<void> removeFavorite(int fairytaleId) async {
    await ApiClient.instance.delete('/favorites/$fairytaleId');
  }
}
