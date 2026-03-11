import 'package:flutter/material.dart';
import '../features/character/screens/character_screen.dart';
import '../features/fairytale_create/screens/fairytale_create_screen.dart';
import '../features/fairytale_list/screens/fairytale_list_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    CharacterScreen(),
    FairytaleCreateScreen(),
    FairytaleListScreen(),
    FavoritesScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.face_retouching_natural, label: '내 캐릭터', color: AppColors.character),
    _NavItem(icon: Icons.auto_stories, label: '동화 만들기', color: AppColors.create),
    _NavItem(icon: Icons.menu_book_rounded, label: '기본 동화', color: AppColors.library),
    _NavItem(icon: Icons.favorite_rounded, label: '찜', color: AppColors.favorites),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? item.color.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected ? item.color : AppColors.textSecondary,
                              size: isSelected ? 26 : 24,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected ? item.color : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.color});
}
