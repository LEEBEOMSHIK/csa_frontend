import 'package:flutter/material.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final List<int> _selectedVariants = [0, 0, 0, 0, 0];
  late final TabController _contentTabController;

  static const _tabs = [
    _TabItem(label: '기본형', icon: Icons.face_rounded),
    _TabItem(label: '머리', icon: Icons.content_cut_rounded),
    _TabItem(label: '눈', icon: Icons.visibility_rounded),
    _TabItem(label: '코', icon: Icons.air_rounded),
    _TabItem(label: '입', icon: Icons.mood_rounded),
  ];

  static const _options = [
    ['둥근형', '각진형', '역삼각형', '하트형', '계란형', '육각형'],
    ['단발', '긴머리', '곱슬', '빡빡이', '포니테일', '모히칸'],
    ['기본눈', '큰눈', '졸린눈', '반달눈', '별눈', '동그란눈'],
    ['작은코', '보통코', '오뚝코', '귀여운코'],
    ['웃음', '미소', '벌린입', '삐침'],
  ];

  static const _activeColor = Color(0xFFFF7043);
  static const _inactiveColor = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _contentTabController = TabController(length: 2, vsync: this);
    _contentTabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _contentTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(
            title: '내 캐릭터',
            actions: [
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          // 콘텐츠 탭바
          Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: _ContentTabItem(
                    label: '이야기',
                    isActive: _contentTabController.index == 0,
                    onTap: () => _contentTabController.animateTo(0),
                  ),
                ),
                Expanded(
                  child: _ContentTabItem(
                    label: '그림조각',
                    isActive: _contentTabController.index == 1,
                    onTap: () => _contentTabController.animateTo(1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _contentTabController,
              children: [
                // 이야기 탭: 캐릭터 미리보기 + 커스터마이즈 패널
                Column(
                  children: [
                    // 캐릭터 미리보기
                    Container(
                      color: const Color(0xFFFFF9E6),
                      width: double.infinity,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFE0B2), width: 3),
                            ),
                            child: const Center(
                              child: Text('😊', style: TextStyle(fontSize: 72)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '나의 캐릭터',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 커스터마이즈 패널
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 왼쪽 파츠 탭
                          Container(
                            width: 72,
                            color: const Color(0xFFFFF3E0),
                            child: Column(
                              children: List.generate(_tabs.length, (index) {
                                final isActive = _selectedTabIndex == index;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTabIndex = index),
                                  child: Container(
                                    height: 64,
                                    width: double.infinity,
                                    color: isActive ? Colors.white : Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _tabs[index].icon,
                                          size: 28,
                                          color: isActive ? _activeColor : _inactiveColor,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _tabs[index].label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                            color: isActive ? _activeColor : _inactiveColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // 오른쪽 옵션 영역
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_tabs[_selectedTabIndex].label} 옵션',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      Text(
                                        '1 / ${((_options[_selectedTabIndex].length + 3) ~/ 4)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: _options[_selectedTabIndex].length,
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            _selectedVariants[_selectedTabIndex] == index;
                                        return GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedVariants[_selectedTabIndex] = index,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? _activeColor.withValues(alpha: 0.1)
                                                  : const Color(0xFFF5F5F5),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? _activeColor
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _options[_selectedTabIndex][index],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? _activeColor
                                                      : const Color(0xFF555555),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 그림조각 탭
                const Center(
                  child: Text(
                    'To be added later',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFAAAAAA),
                    ),
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

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}

class _ContentTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ContentTabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFFFF8C69) : const Color(0xFFE0E0E0),
              width: isActive ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFFFF8C69) : const Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }
}
