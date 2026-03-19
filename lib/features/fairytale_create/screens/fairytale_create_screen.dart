import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/app_colors.dart';

class FairytaleCreateScreen extends StatefulWidget {
  const FairytaleCreateScreen({super.key});

  @override
  State<FairytaleCreateScreen> createState() => _FairytaleCreateScreenState();
}

class _FairytaleCreateScreenState extends State<FairytaleCreateScreen> {
  final Set<int> _settings = {};
  int? _genre;
  int? _theme;
  int? _chapter;    // 0=3ch, 1=5ch, 2=7ch
  int? _character;  // 0=use, 1=skip
  int? _voice;      // 0=dad, 1=mom, 2=grandma, 3=grandpa

  static const int _maxSettings = 3;

  bool get _isReady =>
      _settings.isNotEmpty &&
      _genre != null &&
      _theme != null &&
      _chapter != null &&
      _character != null &&
      _voice != null;

  List<_Item> _settingItems(AppLocalizations l10n) => [
    _Item('🏰', l10n.categoryAdventure, const Color(0xFFFF6B6B)),
    _Item('👨\u200d👩\u200d👧', l10n.categoryFamily, const Color(0xFFFFAA5E)),
    _Item('✨', l10n.categoryFantasy, const Color(0xFF9B5DE5)),
    _Item('🤝', l10n.categoryFriendship, const Color(0xFF06D6A0)),
    _Item('🦁', l10n.categoryAnimal, const Color(0xFFFFD166)),
    _Item('🌊', l10n.categorySea, const Color(0xFF118AB2)),
    _Item('🚀', l10n.categorySpace, const Color(0xFF073B4C)),
    _Item('🧙', l10n.categoryMagic, const Color(0xFFEF476F)),
    _Item('🌳', l10n.categoryForest, const Color(0xFF2DC653)),
    _Item('👑', l10n.categoryKingdom, const Color(0xFFF4C542)),
    _Item('🏫', l10n.categorySchool, const Color(0xFF5BC0F8)),
    _Item('🏙️', l10n.categoryCity, const Color(0xFF8D99AE)),
  ];

  List<_Item> _genreItems(AppLocalizations l10n) => [
    _Item('👸', l10n.genreClassic, const Color(0xFFF4A261)),
    _Item('🏺', l10n.genreFolklore, const Color(0xFFA07850)),
    _Item('😂', l10n.genreComedy, const Color(0xFFFFBF00)),
    _Item('🔍', l10n.genreMystery, const Color(0xFF6C3483)),
    _Item('🤖', l10n.genreScifi, const Color(0xFF1A535C)),
    _Item('🎵', l10n.genreMusical, const Color(0xFFFF6B9D)),
    _Item('🧩', l10n.genreQuiz, const Color(0xFF4ECDC4)),
    _Item('🌈', l10n.genreDaily, const Color(0xFF74B9FF)),
    _Item('💭', l10n.genreDream, const Color(0xFFC39BD3)),
    _Item('👻', l10n.genreHorror, const Color(0xFF636E72)),
  ];

  List<_ThemeData> _themeItems(AppLocalizations l10n) => [
    _ThemeData('📚', l10n.themeMoral),
    _ThemeData('🤝', l10n.themeFriendship),
    _ThemeData('❤️', l10n.themeFamilyLove),
    _ThemeData('⚡', l10n.themeCourage),
    _ThemeData('🌱', l10n.themeGrowth),
    _ThemeData('🎁', l10n.themeSharing),
    _ThemeData('🎨', l10n.themeSelfExpression),
    _ThemeData('🌍', l10n.themeEnvironment),
    _ThemeData('🙏', l10n.themeGratitude),
    _ThemeData('💡', l10n.themeProblemSolving),
    _ThemeData('🔭', l10n.themeCuriosity),
    _ThemeData('🕊️', l10n.themeForgiveness),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingItems = _settingItems(l10n);
    final genreItems = _genreItems(l10n);
    final themeItems = _themeItems(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(title: l10n.createTitle),
          Container(
            width: double.infinity,
            color: AppColors.create,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createQuestion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.createDesc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Setting (max 3)
                  _SectionHeader(
                    title: l10n.createSectionSetting,
                    badge: l10n.createSectionSettingMax,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(settingItems.length, (i) {
                      final item = settingItems[i];
                      final selected = _settings.contains(i);
                      return _SettingChip(
                        emoji: item.emoji,
                        label: item.label,
                        color: item.color,
                        selected: selected,
                        onTap: () => setState(() {
                          if (selected) {
                            _settings.remove(i);
                          } else if (_settings.length < _maxSettings) {
                            _settings.add(i);
                          }
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Section 2: Genre (single)
                  _SectionHeader(title: l10n.createSectionGenre),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: List.generate(genreItems.length, (i) {
                      final item = genreItems[i];
                      return _GenreCard(
                        emoji: item.emoji,
                        label: item.label,
                        color: item.color,
                        selected: _genre == i,
                        onTap: () => setState(() => _genre = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Section 3: Theme (single)
                  _SectionHeader(title: l10n.createSectionTheme),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(themeItems.length, (i) {
                      final chip = themeItems[i];
                      return _ThemeChipWidget(
                        emoji: chip.emoji,
                        label: chip.label,
                        selected: _theme == i,
                        onTap: () => setState(() => _theme = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Section 4: Chapter count
                  _SectionHeader(title: l10n.createSectionChapter),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ChapterCard(
                        number: l10n.chapter3,
                        desc: l10n.chapter3Desc,
                        selected: _chapter == 0,
                        onTap: () => setState(() => _chapter = 0),
                      ),
                      const SizedBox(width: 10),
                      _ChapterCard(
                        number: l10n.chapter5,
                        desc: l10n.chapter5Desc,
                        selected: _chapter == 1,
                        onTap: () => setState(() => _chapter = 1),
                      ),
                      const SizedBox(width: 10),
                      _ChapterCard(
                        number: l10n.chapter7,
                        desc: l10n.chapter7Desc,
                        selected: _chapter == 2,
                        onTap: () => setState(() => _chapter = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section 5: My character
                  _SectionHeader(title: l10n.createSectionCharacter),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CharacterToggleCard(
                        emoji: '🧒',
                        label: l10n.createCharacterUse,
                        desc: l10n.createCharacterUseDesc,
                        color: const Color(0xFF2DC653),
                        selected: _character == 0,
                        onTap: () => setState(() => _character = 0),
                      ),
                      const SizedBox(width: 12),
                      _CharacterToggleCard(
                        emoji: '🤖',
                        label: l10n.createCharacterSkip,
                        desc: l10n.createCharacterSkipDesc,
                        color: const Color(0xFF8D99AE),
                        selected: _character == 1,
                        onTap: () => setState(() => _character = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section 6: Voice
                  _SectionHeader(title: l10n.createSectionVoice),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      _VoiceCard(emoji: '👨', label: l10n.voiceDad,    color: const Color(0xFF118AB2), selected: _voice == 0, onTap: () => setState(() => _voice = 0)),
                      _VoiceCard(emoji: '👩', label: l10n.voiceMom,    color: const Color(0xFFFF6B9D), selected: _voice == 1, onTap: () => setState(() => _voice = 1)),
                      _VoiceCard(emoji: '👵', label: l10n.voiceGrandma, color: const Color(0xFF9B5DE5), selected: _voice == 2, onTap: () => setState(() => _voice = 2)),
                      _VoiceCard(emoji: '👴', label: l10n.voiceGrandpa, color: const Color(0xFFF4A261), selected: _voice == 3, onTap: () => setState(() => _voice = 3)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isReady ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.create,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _isReady
                            ? l10n.createBtnReady
                            : l10n.createBtnNotReady,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data holders ─────────────────────────────────────────────────────────────

class _Item {
  final String emoji;
  final String label;
  final Color color;
  const _Item(this.emoji, this.label, this.color);
}

class _ThemeData {
  final String emoji;
  final String label;
  const _ThemeData(this.emoji, this.label);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.create.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.create,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SettingChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: selected ? 0.3 : 0.08),
              blurRadius: selected ? 8 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _GenreCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: selected ? 0.3 : 0.08),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChipWidget extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChipWidget({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _selectedColor = Color(0xFF9B5DE5);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _selectedColor : const Color(0xFFF4F4F8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final String number;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.number,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  static const _selectedColor = Color(0xFF118AB2);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? _selectedColor : _selectedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _selectedColor : _selectedColor.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _selectedColor.withValues(alpha: selected ? 0.3 : 0.08),
                blurRadius: selected ? 10 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterToggleCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CharacterToggleCard({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: selected ? 0.3 : 0.08),
                blurRadius: selected ? 10 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _VoiceCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: selected ? 0.3 : 0.08),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

