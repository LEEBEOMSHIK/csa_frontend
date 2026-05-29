import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/features/character/services/character_service.dart';
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

  // 현재 편집 중인 캐릭터의 서버 ID (저장된 적 없으면 null → 신규 생성)
  int? _currentCharacterId;
  bool _isSaving = false;

  static const _activeColor = Color(0xFFFF7043);
  static const _inactiveColor = Color(0xFF999999);

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

  @override
  void initState() {
    super.initState();
    _contentTabController = TabController(length: 2, vsync: this);
    _contentTabController.addListener(() => setState(() {}));
    _characterGame = CharacterGame(variants: List.from(_selectedVariants));
    _loadLatestCharacter();
  }

  @override
  void dispose() {
    _contentTabController.dispose();
    super.dispose();
  }

  /// 서버에 저장된 가장 최근 캐릭터를 불러와 편집기에 반영
  Future<void> _loadLatestCharacter() async {
    try {
      final characters = await CharacterService.instance.fetchMyCharacters();
      if (characters.isEmpty || !mounted) return;
      final latest = characters.first;
      if (latest.variants.length != _selectedVariants.length) return;
      setState(() {
        _currentCharacterId = latest.id;
        for (var i = 0; i < _selectedVariants.length; i++) {
          _selectedVariants[i] = latest.variants[i];
        }
      });
      _characterGame.equipItem(_selectedVariants);
    } catch (_) {
      // 미로그인/네트워크 실패 시 기본 캐릭터 유지
    }
  }

  Future<void> _onSaveTap() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    final name = await _promptName(l10n);
    if (name == null || name.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final variants = List<int>.from(_selectedVariants);
      final saved = _currentCharacterId == null
          ? await CharacterService.instance.create(name.trim(), variants)
          : await CharacterService.instance
              .update(_currentCharacterId!, name.trim(), variants);
      if (!mounted) return;
      setState(() => _currentCharacterId = saved.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.characterSaved)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.characterSaveError)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String?> _promptName(AppLocalizations l10n) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.characterSaveTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: InputDecoration(hintText: l10n.characterNameHint),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.characterCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n.characterSaveAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _buildTabs(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          // ── 상단 바 ──
          AppTopBar(
            title: l10n.characterTitle,
            actions: [
              GestureDetector(
                onTap: _isSaving ? null : _onSaveTap,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded,
                          color: Colors.white, size: 24),
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
                          const Expanded(
                            child: ColoredBox(color: Color(0xFFF8F6EE)),
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
