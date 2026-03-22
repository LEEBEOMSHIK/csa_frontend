import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/features/character/screens/character_screen.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_create_screen.dart';
import 'package:csa_frontend/features/home/screens/home_screen.dart';
import 'package:csa_frontend/features/favorites/screens/favorites_screen.dart';
import 'package:csa_frontend/features/my/screens/my_screen.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.debugLoginData});

  final Map<String, dynamic>? debugLoginData;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _debugPanelVisible = true;

  static const List<Widget> _screens = [
    CharacterScreen(),
    FairytaleCreateScreen(),
    HomeScreen(),
    FavoritesScreen(),
    MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mainTabNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.debugLoginData != null && _debugPanelVisible)
                _DebugDataPanel(
                  data: widget.debugLoginData!,
                  onClose: () => setState(() => _debugPanelVisible = false),
                ),
              _BottomNav(
                currentIndex: currentIndex,
                onTap: (i) => mainTabNotifier.value = i,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _activeColor = Color(0xFFFE9EC7);
  static const _inactiveColor = Color(0xFFBBBBBB);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.face_retouching_natural_rounded,
                label: l10n.navCharacter,
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.auto_stories_rounded,
                label: l10n.navFairytale,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              // 가운데 홈 버튼
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _activeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _activeColor.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.navHome,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: currentIndex == 2
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: l10n.navFavorites,
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.navMy,
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugDataPanel extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;

  const _DebugDataPanel({required this.data, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '[DEBUG] /auth/login response',
                style: TextStyle(
                  color: Color(0xFF00FF88),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Color(0xFF888888), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${e.key}: ',
                        style: const TextStyle(
                          color: Color(0xFF82AAFF),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      TextSpan(
                        text: _format(e.value),
                        style: const TextStyle(
                          color: Color(0xFFFFCB6B),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    );
  }

  String _format(dynamic value) {
    if (value is String && value.length > 40) {
      return '${value.substring(0, 40)}…';
    }
    return '$value';
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
