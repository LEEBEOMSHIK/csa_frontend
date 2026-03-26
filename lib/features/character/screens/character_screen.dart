import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/features/character/widgets/character_game.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  // 0=전체, 1=모자, 2=상의, 3=하의, 4=안경, 5=악세서리
  int _selectedTabIndex = 0;

  // [0]=hat, [1]=top, [2]=bottom, [3]=glasses, [4]=accessory,
  // [5]=face, [6]=eyes, [7]=nose, [8]=mouth
  final List<int> _selectedVariants = [0, 0, 0, 0, 0, 1, 1, 1, 1];

  late final TabController _contentTabController;
  late final CharacterGame _characterGame;

  static const _activeColor = Color(0xFFFF7043);
  static const _inactiveColor = Color(0xFF999999);
  static const _checkColor = Color(0xFF5CB85C);

  // ── 탭 정의 ────────────────────────────────────────────────────────────────
  List<_TabItem> _buildTabs(AppLocalizations l10n) => [
        _TabItem(label: l10n.characterTabAll,       icon: Icons.grid_view_rounded),
        _TabItem(label: l10n.characterTabHat,       icon: Icons.military_tech_rounded),
        _TabItem(label: l10n.characterTabTop,       icon: Icons.checkroom_rounded),
        _TabItem(label: l10n.characterTabBottom,    icon: Icons.layers_rounded),
        _TabItem(label: l10n.characterTabGlasses,   icon: Icons.wb_sunny_outlined),
        _TabItem(label: l10n.characterTabAccessory, icon: Icons.auto_awesome_rounded),
        _TabItem(label: l10n.characterTabFace,      icon: Icons.face_rounded),
        _TabItem(label: l10n.characterTabEyes,      icon: Icons.remove_red_eye_rounded),
        _TabItem(label: l10n.characterTabNose,      icon: Icons.airline_seat_flat),
        _TabItem(label: l10n.characterTabMouth,     icon: Icons.sentiment_satisfied_rounded),
      ];

  // ── 아이템 데이터 ───────────────────────────────────────────────────────────
  static const _hatItems = <_ItemData>[
    _ItemData(categoryIndex: 0, variantIndex: 0, label: '없음', color: Color(0xFFDDDDDD), isNone: true),
    _ItemData(categoryIndex: 0, variantIndex: 1, label: '악마 투구', color: Color(0xFFB22222)),
    _ItemData(categoryIndex: 0, variantIndex: 2, label: '파라오', color: Color(0xFFD4AC0D)),
    _ItemData(categoryIndex: 0, variantIndex: 3, label: '카우보이', color: Color(0xFF7B4F2E)),
    _ItemData(categoryIndex: 0, variantIndex: 4, label: '마법사', color: Color(0xFF6B2FA0)),
  ];

  static const _topItems = <_ItemData>[
    _ItemData(categoryIndex: 1, variantIndex: 0, label: '없음', color: Color(0xFFDDDDDD), isNone: true),
    _ItemData(categoryIndex: 1, variantIndex: 1, label: '흰 티셔츠', color: Color(0xFFE0E0E0)),
    _ItemData(categoryIndex: 1, variantIndex: 2, label: '꽃무늬', color: Color(0xFFFF8FAB)),
    _ItemData(categoryIndex: 1, variantIndex: 3, label: '줄무늬', color: Color(0xFF4488CC)),
    _ItemData(categoryIndex: 1, variantIndex: 4, label: '정장', color: Color(0xFF2C3E50)),
  ];

  static const _bottomItems = <_ItemData>[
    _ItemData(categoryIndex: 2, variantIndex: 0, label: '없음', color: Color(0xFFDDDDDD), isNone: true),
    _ItemData(categoryIndex: 2, variantIndex: 1, label: '청바지', color: Color(0xFF3A5FA0)),
    _ItemData(categoryIndex: 2, variantIndex: 2, label: '반바지', color: Color(0xFFB8965A)),
    _ItemData(categoryIndex: 2, variantIndex: 3, label: '스커트', color: Color(0xFFE05580)),
  ];

  static const _glassesItems = <_ItemData>[
    _ItemData(categoryIndex: 3, variantIndex: 0, label: '없음', color: Color(0xFFDDDDDD), isNone: true),
    _ItemData(categoryIndex: 3, variantIndex: 1, label: '선글라스', color: Color(0xFF1A6B1A)),
    _ItemData(categoryIndex: 3, variantIndex: 2, label: '둥근 안경', color: Color(0xFFD4A017)),
    _ItemData(categoryIndex: 3, variantIndex: 3, label: '별 안경', color: Color(0xFFCC44AA)),
  ];

  static const _accessoryItems = <_ItemData>[
    _ItemData(categoryIndex: 4, variantIndex: 0, label: '없음', color: Color(0xFFDDDDDD), isNone: true),
    _ItemData(categoryIndex: 4, variantIndex: 1, label: '하트 머그', color: Color(0xFFCC2244)),
    _ItemData(categoryIndex: 4, variantIndex: 2, label: '책', color: Color(0xFF226688)),
    _ItemData(categoryIndex: 4, variantIndex: 3, label: '별 지팡이', color: Color(0xFFCCAA00)),
  ];

  // 얼굴형 (없음 없음 — 항상 하나 선택)
  static const _faceItems = <_ItemData>[
    _ItemData(categoryIndex: 5, variantIndex: 1, label: '둥근 얼굴', color: Color(0xFFFFCBAA), imagePath: 'assets/character_parts/base/head_01.png'),
    _ItemData(categoryIndex: 5, variantIndex: 2, label: '타원 얼굴', color: Color(0xFFFFD9B7), imagePath: 'assets/character_parts/base/head_02.png'),
    _ItemData(categoryIndex: 5, variantIndex: 3, label: '각진 얼굴', color: Color(0xFFD4A017)),
    _ItemData(categoryIndex: 5, variantIndex: 4, label: '넓은 얼굴', color: Color(0xFF8B1A1A)),
  ];

  static const _eyesItems = <_ItemData>[
    _ItemData(categoryIndex: 6, variantIndex: 1, label: '기본 눈', color: Color(0xFFE8F4FF), imagePath: 'assets/character_parts/eyes/eyes_01.png'),
    _ItemData(categoryIndex: 6, variantIndex: 2, label: '반짝 눈', color: Color(0xFFEDE8FF), imagePath: 'assets/character_parts/eyes/eyes_02.png'),
    _ItemData(categoryIndex: 6, variantIndex: 3, label: '졸린 눈', color: Color(0xFFE8F0F4), imagePath: 'assets/character_parts/eyes/eyes_03.png'),
    _ItemData(categoryIndex: 6, variantIndex: 4, label: '별 눈', color: Color(0xFFFF9800)),
  ];

  static const _noseItems = <_ItemData>[
    _ItemData(categoryIndex: 7, variantIndex: 1, label: '점 코', color: Color(0xFFFFECDF), imagePath: 'assets/character_parts/nose/nose_01.png'),
    _ItemData(categoryIndex: 7, variantIndex: 2, label: '버튼 코', color: Color(0xFFFFE8D6), imagePath: 'assets/character_parts/nose/nose_02.png'),
    _ItemData(categoryIndex: 7, variantIndex: 3, label: '주근깨', color: Color(0xFFF4A460)),
    _ItemData(categoryIndex: 7, variantIndex: 4, label: '들창코', color: Color(0xFFDEB887)),
  ];

  static const _mouthItems = <_ItemData>[
    _ItemData(categoryIndex: 8, variantIndex: 1, label: '미소', color: Color(0xFFFFEEF2), imagePath: 'assets/character_parts/mouth/mouth_01.png'),
    _ItemData(categoryIndex: 8, variantIndex: 2, label: '활짝', color: Color(0xFFFFE0E4), imagePath: 'assets/character_parts/mouth/mouth_02.png'),
    _ItemData(categoryIndex: 8, variantIndex: 3, label: '무표정', color: Color(0xFFEEF2F4), imagePath: 'assets/character_parts/mouth/mouth_03.png'),
    _ItemData(categoryIndex: 8, variantIndex: 4, label: '애교', color: Color(0xFFFF80AB)),
  ];

  List<_ItemData> _getCurrentItems() {
    switch (_selectedTabIndex) {
      case 0:
        return [
          ..._hatItems.where((i) => !i.isNone),
          ..._topItems.where((i) => !i.isNone),
          ..._bottomItems.where((i) => !i.isNone),
          ..._glassesItems.where((i) => !i.isNone),
          ..._accessoryItems.where((i) => !i.isNone),
          ..._faceItems,
          ..._eyesItems,
          ..._noseItems,
          ..._mouthItems,
        ];
      case 1:  return _hatItems;
      case 2:  return _topItems;
      case 3:  return _bottomItems;
      case 4:  return _glassesItems;
      case 5:  return _accessoryItems;
      case 6:  return _faceItems;
      case 7:  return _eyesItems;
      case 8:  return _noseItems;
      case 9:  return _mouthItems;
      default: return _hatItems;
    }
  }

  @override
  void initState() {
    super.initState();
    _contentTabController = TabController(length: 2, vsync: this);
    _contentTabController.addListener(() => setState(() {}));
    _characterGame = CharacterGame(variants: List.from(_selectedVariants));
  }

  @override
  void dispose() {
    _contentTabController.dispose();
    super.dispose();
  }

  void _selectItem(_ItemData item) {
    setState(() {
      _selectedVariants[item.categoryIndex] = item.variantIndex;
    });
    _characterGame.equipItem(List.from(_selectedVariants));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _buildTabs(l10n);
    final items = _getCurrentItems();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          // ── 상단 바 ──
          AppTopBar(
            title: l10n.characterTitle,
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

          // ── 컨텐츠 탭 (스토리 / 그림조각) ──
          Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: _ContentTabItem(
                    label: l10n.homeTabStory,
                    isActive: _contentTabController.index == 0,
                    onTap: () => _contentTabController.animateTo(0),
                  ),
                ),
                Expanded(
                  child: _ContentTabItem(
                    label: l10n.homeTabPicture,
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
                // ── 스토리 탭 ──
                Column(
                  children: [
                    // ── Flame 캐릭터 미리보기 영역 ──
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Stack(
                        children: [
                          // Flame GameWidget
                          GameWidget(game: _characterGame),
                          // 캐릭터 이름 라벨 (하단)
                          Positioned(
                            bottom: 28,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.characterMyCharacter,
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── 사이드 탭 + 아이템 그리드 ──
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 왼쪽 사이드 탭 ──
                          Container(
                            width: 72,
                            color: const Color(0xFFFFF3E0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(tabs.length, (index) {
                                  final isActive = _selectedTabIndex == index;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedTabIndex = index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      height: 60,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.transparent,
                                        border: isActive
                                            ? const Border(
                                                left: BorderSide(
                                                  color: Color(0xFFFF7043),
                                                  width: 3,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            tabs[index].icon,
                                            size: 24,
                                            color: isActive
                                                ? _activeColor
                                                : _inactiveColor,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            tabs[index].label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isActive
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isActive
                                                  ? _activeColor
                                                  : _inactiveColor,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // ── 오른쪽 아이템 그리드 ──
                          Expanded(
                            child: Container(
                              color: const Color(0xFFF8F6EE),
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      l10n.characterOptionTitle(
                                          tabs[_selectedTabIndex].label),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF555533),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 7,
                                        mainAxisSpacing: 7,
                                        childAspectRatio: 1.0,
                                      ),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        final isSelected =
                                            _selectedVariants[
                                                    item.categoryIndex] ==
                                                item.variantIndex;
                                        return _ItemCard(
                                          item: item,
                                          isSelected: isSelected,
                                          checkColor: _checkColor,
                                          onTap: () => _selectItem(item),
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

                // ── 그림조각 탭 ──
                const Center(
                  child: Text(
                    'To be added later',
                    style: TextStyle(fontSize: 16, color: Color(0xFFAAAAAA)),
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

// ─────────────────────────────────────────────────────────────────────────────
// 아이템 데이터 모델
// ─────────────────────────────────────────────────────────────────────────────

class _ItemData {
  final int categoryIndex;
  final int variantIndex;
  final String label;
  final Color color;
  final bool isNone;
  final String? imagePath;

  const _ItemData({
    required this.categoryIndex,
    required this.variantIndex,
    required this.label,
    required this.color,
    this.isNone = false,
    this.imagePath,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 아이템 카드 — 2D 게임 스타일
// ─────────────────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final _ItemData item;
  final bool isSelected;
  final Color checkColor;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.isSelected,
    required this.checkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: item.isNone
              ? const LinearGradient(
                  colors: [Color(0xFFEEECE4), Color(0xFFDDDAD0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.55),
                    item.color.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? checkColor : Colors.white.withValues(alpha: 0.6),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? checkColor.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 7 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 카드 내용
            if (item.isNone)
              Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBBBBBB),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Color(0xFFBBBBBB),
                    size: 18,
                  ),
                ),
              )
            else if (item.imagePath != null)
              // 이미지 에셋 표시
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        item.imagePath!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 8,
                          color: _textColorFor(item.color),
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9,
                      color: _textColorFor(item.color),
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // 선택 배지
            if (isSelected)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: checkColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: checkColor.withValues(alpha: 0.45),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _textColorFor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.45 ? const Color(0xFF444422) : Colors.white;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헬퍼 클래스
// ─────────────────────────────────────────────────────────────────────────────

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
              color: isActive
                  ? const Color(0xFFFF8C69)
                  : const Color(0xFFE0E0E0),
              width: isActive ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? const Color(0xFFFF8C69)
                : const Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }
}
