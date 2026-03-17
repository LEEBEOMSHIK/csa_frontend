import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    return Scaffold(
      body: Column(
        children: [
          // Top section — brand area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFE8D6), Color(0xFFFFFDF5)],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  const Positioned(
                    left: 40,
                    top: 70,
                    child: Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                  ),
                  const Positioned(
                    right: 30,
                    top: 50,
                    child: Icon(Icons.auto_awesome,
                        color: Color(0xFFFFA7A7), size: 22),
                  ),
                  const Positioned(
                    right: 50,
                    top: 110,
                    child: Icon(Icons.star, color: Color(0xFFB4A7E5), size: 14),
                  ),
                  Positioned(
                    left: 50,
                    top: 130,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB7CE),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 160,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA8E6CF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 210,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB4A7E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Brand content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.loginAppTitle,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFA7A7),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginAppSubtitle,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Illustration
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final size = MediaQuery.of(context).size;
                            final imageSize = size.width * 0.55;
                            return Image.asset(
                              'assets/images/login/이야기 숲.png',
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom section — login buttons
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF5BBFAB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Google login button
                _LoginButton(
                  onTap: () {},
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF333333),
                  borderColor: const Color(0xFFE0E0E0),
                  icon: _GoogleIcon(),
                  label: l10n.loginWithGoogle,
                ),
                const SizedBox(height: 12),

                // Korean: Kakao / Japanese: Yahoo Japan
                if (isKorean)
                  _LoginButton(
                    onTap: () {},
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: const Color(0xFF3C1E1E),
                    icon: const _KakaoIcon(),
                    label: l10n.loginWithKakao,
                  )
                else
                  _LoginButton(
                    onTap: () {},
                    backgroundColor: const Color(0xFFFF0033),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.search, color: Colors.white, size: 20),
                    label: l10n.loginWithYahoo,
                  ),
                const SizedBox(height: 12),

                // Apple login button
                _LoginButton(
                  onTap: () {},
                  backgroundColor: const Color(0xFF333333),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.apple, color: Colors.white, size: 20),
                  label: l10n.loginWithApple,
                ),
                const SizedBox(height: 12),

                // Test button
                _LoginButton(
                  onTap: () => _navigateToHome(context),
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.skip_next_rounded,
                      color: Colors.white, size: 20),
                  label: l10n.loginTestSkip,
                ),
                const SizedBox(height: 16),

                // Footer text
                Text(
                  l10n.loginFooter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    this.borderColor,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'G',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFF4285F4),
          height: 1.2,
        ),
      ),
    );
  }
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF3C1E1E),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.chat_bubble, color: Color(0xFFFEE500), size: 14),
    );
  }
}
