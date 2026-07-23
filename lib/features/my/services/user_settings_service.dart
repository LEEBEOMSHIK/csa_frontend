import 'package:csa_frontend/features/my/models/user_settings.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

abstract class UserSettingsApiClient {
  Future<dynamic> get(String path);
  Future<dynamic> put(String path, {Object? data});
  Future<dynamic> post(String path, {Object? data});
}

class _DefaultUserSettingsApiClient implements UserSettingsApiClient {
  @override
  Future<dynamic> get(String path) => ApiClient.instance.get(path);

  @override
  Future<dynamic> put(String path, {Object? data}) =>
      ApiClient.instance.put(path, data: data);

  @override
  Future<dynamic> post(String path, {Object? data}) =>
      ApiClient.instance.post(path, data: data);
}

class UserSettingsService {
  final UserSettingsApiClient _api;

  UserSettingsService({UserSettingsApiClient? api})
    : _api = api ?? _DefaultUserSettingsApiClient();

  static final UserSettingsService instance = UserSettingsService();

  Future<UserSettings> fetchSettings() async {
    final data = await _api.get('/users/settings');
    final settings = UserSettings.fromJson(data as Map<String, dynamic>);
    isPremiumNotifier.value = settings.isPremium;
    return settings;
  }

  /// 세 필드 모두 필수로 전송. 변경된 설정을 반환한다.
  Future<UserSettings> updateSettings(UserSettings settings) async {
    final data = await _api.put('/users/settings', data: settings.toJson());
    return UserSettings.fromJson(data as Map<String, dynamic>);
  }

  /// QA용 구독 등급 변경(dev/local 한정, prod 비활성).
  /// 갱신된 설정을 반환하고 전역 PREMIUM 캐시를 함께 동기화한다.
  Future<UserSettings> setSubscriptionTier(String tier) async {
    final data = await _api.post(
      '/users/settings/subscription',
      data: {'tier': tier},
    );
    final settings = UserSettings.fromJson(data as Map<String, dynamic>);
    isPremiumNotifier.value = settings.isPremium;
    return settings;
  }

  /// type별 최신 1건. 미동의 type은 생략되어 반환된다.
  Future<List<TermAgreement>> fetchTerms() async {
    final data = await _api.get('/users/terms');
    return (data as List<dynamic>)
        .map((e) => TermAgreement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// {type} path는 소문자(service|finance|privacy). 동일 (type,version) 재호출은 멱등.
  Future<void> agreeTerm(TermType type, String termVersion) async {
    await _api.post(
      '/users/terms/${type.pathName}',
      data: {'termVersion': termVersion},
    );
  }
}
