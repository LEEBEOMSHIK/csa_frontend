import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csa_frontend/features/admin/screens/admin_home_screen.dart';
import 'package:csa_frontend/features/auth/services/google_auth_service.dart';
import 'package:csa_frontend/features/my/services/user_settings_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

const _testEmail = 'test@test.com';
const _testPassword = 'test1234';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  static const _storage = FlutterSecureStorage();

  bool _loading = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _afterTokensStored() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final settings = await UserSettingsService.instance.fetchSettings();
      if (!settings.isAdmin) {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
        _showMessage(l10n.adminLoginNoPermission);
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    } catch (e) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      _showMessage('${l10n.adminLoginFailed}: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await GoogleAuthService.signIn(locale);
      if (!mounted) return;
      await _afterTokensStored();
    } catch (e) {
      _showMessage('${l10n.adminLoginFailed}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _testLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      // 1) 회원가입 시도 (이미 존재하면 무시)
      try {
        await ApiClient.instance.post(
          '/auth/signup',
          data: {'email': _testEmail, 'password': _testPassword},
        );
      } catch (_) {}

      // 2) 로그인 → 토큰 수령
      final tokens =
          await ApiClient.instance.post(
                '/auth/login',
                data: {'email': _testEmail, 'password': _testPassword},
              )
              as Map<String, dynamic>;

      final accessToken = tokens['accessToken'] as String?;
      final refreshToken = tokens['refreshToken'] as String?;
      if (accessToken == null) {
        _showMessage(l10n.adminLoginFailed);
        return;
      }

      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      if (!mounted) return;
      await _afterTokensStored();
    } catch (e) {
      _showMessage('${l10n.adminLoginFailed}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.adminLoginTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.adminLoginSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 32),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _signInWithGoogle,
                          child: Text(l10n.adminLoginWithGoogle),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _testLogin,
                          child: Text(l10n.adminLoginTestLogin),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
