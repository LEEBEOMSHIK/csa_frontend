import 'package:flutter/material.dart';
import 'package:csa_frontend/features/character/screens/character_screen.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_create_screen.dart';
import 'package:csa_frontend/features/home/screens/home_screen.dart';
import 'package:csa_frontend/features/favorites/screens/favorites_screen.dart';
import 'package:csa_frontend/features/my/screens/my_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  static const List<Widget> _screens = [
    CharacterScreen(),
    FairytaleCreateScreen(),
    HomeScreen(),
    FavoritesScreen(),
    MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
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
                label: '내 캐릭터',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.auto_stories_rounded,
                label: '동화',
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
                        '홈',
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
                label: '찜목록',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: '마이',
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
