import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/models/user_settings.dart';
import 'package:csa_frontend/features/my/services/user_settings_service.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

void main() {
  test('fetchSettings parses camelCase boolean flags', () async {
    final api = _FakeApi(getResponse: {
      'locale': 'ja',
      'textNotiEnabled': true,
      'pushNotiEnabled': false,
    });
    final service = UserSettingsService(api: api);

    final settings = await service.fetchSettings();

    expect(api.getPath, '/users/settings');
    expect(settings.locale, 'ja');
    expect(settings.textNotiEnabled, true);
    expect(settings.pushNotiEnabled, false);
  });

  test('fetchSettings parses subscriptionTier and syncs isPremiumNotifier',
      () async {
    final api = _FakeApi(getResponse: {
      'locale': 'ko',
      'textNotiEnabled': true,
      'pushNotiEnabled': true,
      'subscriptionTier': 'PREMIUM',
    });
    final service = UserSettingsService(api: api);

    final settings = await service.fetchSettings();

    expect(settings.subscriptionTier, 'PREMIUM');
    expect(settings.isPremium, true);
    expect(isPremiumNotifier.value, true);
  });

  test('UserSettings defaults missing subscriptionTier to FREE', () {
    final settings = UserSettings.fromJson({
      'locale': 'ko',
      'textNotiEnabled': true,
      'pushNotiEnabled': true,
    });

    expect(settings.subscriptionTier, 'FREE');
    expect(settings.isPremium, false);
  });

  test('setSubscriptionTier posts tier and updates cache', () async {
    isPremiumNotifier.value = false;
    final api = _FakeApi(postResponse: {
      'locale': 'ko',
      'textNotiEnabled': true,
      'pushNotiEnabled': true,
      'subscriptionTier': 'PREMIUM',
    });
    final service = UserSettingsService(api: api);

    final updated = await service.setSubscriptionTier('PREMIUM');

    expect(api.postPath, '/users/settings/subscription');
    expect(api.postData, {'tier': 'PREMIUM'});
    expect(updated.isPremium, true);
    expect(isPremiumNotifier.value, true);
  });

  test('updateSettings sends all three fields and parses response', () async {
    final api = _FakeApi(putResponse: {
      'locale': 'ja',
      'textNotiEnabled': true,
      'pushNotiEnabled': false,
    });
    final service = UserSettingsService(api: api);

    final updated = await service.updateSettings(
      const UserSettings(
        locale: 'ja',
        textNotiEnabled: true,
        pushNotiEnabled: false,
      ),
    );

    expect(api.putPath, '/users/settings');
    expect(api.putData, {
      'locale': 'ja',
      'textNotiEnabled': true,
      'pushNotiEnabled': false,
    });
    expect(updated.pushNotiEnabled, false);
  });

  test('fetchTerms maps uppercase termType to enum', () async {
    final api = _FakeApi(getResponse: [
      {
        'termType': 'SERVICE',
        'termVersion': 'v1.0',
        'agreedAt': '2026-06-16T22:00:00',
      },
      {
        'termType': 'PRIVACY',
        'termVersion': 'v1.0',
        'agreedAt': '2026-06-16T22:00:00',
      },
    ]);
    final service = UserSettingsService(api: api);

    final terms = await service.fetchTerms();

    expect(api.getPath, '/users/terms');
    expect(terms.length, 2);
    expect(terms.first.termType, TermType.service);
    expect(terms.first.termVersion, 'v1.0');
    expect(terms[1].termType, TermType.privacy);
  });

  test('agreeTerm uses lowercase path and termVersion body', () async {
    final api = _FakeApi();
    final service = UserSettingsService(api: api);

    await service.agreeTerm(TermType.finance, 'v1.0');

    expect(api.postPath, '/users/terms/finance');
    expect(api.postData, {'termVersion': 'v1.0'});
  });
}

class _FakeApi implements UserSettingsApiClient {
  final dynamic getResponse;
  final dynamic putResponse;
  final dynamic postResponse;

  String? getPath;
  String? putPath;
  Object? putData;
  String? postPath;
  Object? postData;

  _FakeApi({this.getResponse, this.putResponse, this.postResponse});

  @override
  Future<dynamic> get(String path) async {
    getPath = path;
    return getResponse;
  }

  @override
  Future<dynamic> put(String path, {Object? data}) async {
    putPath = path;
    putData = data;
    return putResponse;
  }

  @override
  Future<dynamic> post(String path, {Object? data}) async {
    postPath = path;
    postData = data;
    return postResponse;
  }
}
