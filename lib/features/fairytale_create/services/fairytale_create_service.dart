import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_request.dart';
import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class FairytaleCreateService {
  FairytaleCreateService._();
  static final FairytaleCreateService instance = FairytaleCreateService._();

  final _api = ApiClient.instance;

  Future<FairytaleGenerateResponse> generate(FairytaleGenerateRequest request) async {
    final data = await _api.post('/fairytale/generate', data: request.toJson());
    return FairytaleGenerateResponse.fromJson(data as Map<String, dynamic>);
  }
}
