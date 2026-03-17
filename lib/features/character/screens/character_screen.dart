import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
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

  static const _activeColor = Color(0xFFFF7043);
  static const _inactiveColor = Color(0xFF999999);

  List<_TabItem> _buildTabs(AppLocalizations l10n) => [
    _TabItem(label: l10n.characterTabBasic, icon: Icons.face_rounded),
    _TabItem(label: l10n.characterTabHair, icon: Icons.content_cut_rounded),
    _TabItem(label: l10n.characterTabEyes, icon: Icons.visibility_rounded),
    _TabItem(label: l10n.characterTabNose, icon: Icons.air_rounded),
    _TabItem(label: l10n.characterTabMouth, icon: Icons.mood_rounded),
  ];

  List<List<String>> _buildOptions(AppLocalizations l10n) => [
    [l10n.faceRound, l10n.faceSquare, l10n.faceInvTriangle,
     l10n.faceHeart, l10n.faceEgg, l10n.faceHex],
    [l10n.hairBob, l10n.hairLong, l10n.hairCurly,
     l10n.hairBuzz, l10n.hairPony, l10n.hairMohawk],
    [l10n.eyeDefault, l10n.eyeBig, l10n.eyeSleepy,
     l10n.eyeCrescent, l10n.eyeStar, l10n.eyeRound],
    [l10n.noseSmall, l10n.noseNormal, l10n.noseHigh, l10n.noseCute],
    [l10n.mouthSmile, l10n.mouthGrin, l10n.mouthOpen, l10n.mouthPout],
  ];

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
    final l10n = AppLocalizations.of(context)!;
    final tabs = _buildTabs(l10n);
    final options = _buildOptions(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(
            title: l10n.characterTitle,
            actions: [
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
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
                Column(
                  children: [
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
                              border: Border.all(
                                  color: const Color(0xFFFFE0B2), width: 3),
                            ),
                            child: const Center(
                              child: Text('😊',
                                  style: TextStyle(fontSize: 72)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.characterMyCharacter,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 72,
                            color: const Color(0xFFFFF3E0),
                            child: Column(
                              children: List.generate(tabs.length, (index) {
                                final isActive = _selectedTabIndex == index;
                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedTabIndex = index),
                                  child: Container(
                                    height: 64,
                                    width: double.infinity,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          tabs[index].icon,
                                          size: 28,
                                          color: isActive
                                              ? _activeColor
                                              : _inactiveColor,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tabs[index].label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isActive
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isActive
                                                ? _activeColor
                                                : _inactiveColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.characterOptionTitle(
                                            tabs[_selectedTabIndex].label),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      Text(
                                        '1 / ${((options[_selectedTabIndex].length + 3) ~/ 4)}',
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
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount:
                                          options[_selectedTabIndex].length,
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            _selectedVariants[
                                                    _selectedTabIndex] ==
                                                index;
                                        return GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedVariants[
                                                _selectedTabIndex] = index,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? _activeColor.withValues(
                                                      alpha: 0.1)
                                                  : const Color(0xFFF5F5F5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? _activeColor
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                options[_selectedTabIndex]
                                                    [index],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? _activeColor
                                                      : const Color(
                                                          0xFF555555),
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
            color:
                isActive ? const Color(0xFFFF8C69) : const Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }
}
