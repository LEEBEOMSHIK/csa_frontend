import 'package:flutter/material.dart';

import 'package:csa_frontend/features/character/screens/character_screen.dart';
import 'package:csa_frontend/features/favorites/screens/favorites_screen.dart';
import 'package:csa_frontend/features/favorites/services/favorite_service.dart';
import 'package:csa_frontend/features/home/screens/home_screen.dart';
import 'package:csa_frontend/features/my/screens/my_screen.dart';
import 'package:csa_frontend/features/my/services/user_settings_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.debugLoginData});

  final Map<String, dynamic>? debugLoginData;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSettings();
  }

  Future<void> _loadFavorites() async {
    try {
      final items = await FavoriteService.instance.fetchFavorites();
      favoritesNotifier.value = items;
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await UserSettingsService.instance.fetchSettings();
      localeNotifier.value = Locale(settings.locale);
      textNotiNotifier.value = settings.textNotiEnabled;
      pushNotiNotifier.value = settings.pushNotiEnabled;
    } catch (_) {}
  }

  static const List<Widget> _screens = [
    CharacterScreen(),
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
          body: IndexedStack(index: currentIndex, children: _screens),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
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
                icon: Icons.home_rounded,
                label: l10n.navHome,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: l10n.navFavorites,
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.navMy,
                index: 3,
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
      child: Semantics(
        selected: isSelected,
        button: true,
        label: label,
        excludeSemantics: true,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
