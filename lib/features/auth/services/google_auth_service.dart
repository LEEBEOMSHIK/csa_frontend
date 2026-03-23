import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

const _webClientId =
    '279288031280-6on9q9g2m5abg7960prrcr3gmvup0f2u.apps.googleusercontent.com';

class GoogleAuthService {
  static const _storage = FlutterSecureStorage();

  // clientId: 웹에서 사용 (GIS 팝업)
  // serverClientId: Android/iOS 배포 시 idToken audience 지정용 (추후 추가)
  static final _googleSignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: ['email', 'profile', 'openid'],
  );

  static Future<Map<String, dynamic>> signIn(String locale) async {
    await _googleSignIn.signOut();

    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in cancelled');

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('Failed to get access token from Google');

    final response = await ApiClient.instance.post(
      '/auth/oauth/google',
      data: {'accessToken': accessToken, 'locale': locale},
    ) as Map<String, dynamic>;

    await _storage.write(
        key: 'access_token', value: response['accessToken'] as String);
    await _storage.write(
        key: 'refresh_token', value: response['refreshToken'] as String);

    return response;
  }
}
