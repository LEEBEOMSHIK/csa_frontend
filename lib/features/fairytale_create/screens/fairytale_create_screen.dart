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
  int? _selectedCategory;

  List<_Category> _buildCategories(AppLocalizations l10n) => [
    _Category(emoji: '🏰', label: l10n.categoryAdventure, color: const Color(0xFFFF6B6B)),
    _Category(emoji: '👨‍👩‍👧', label: l10n.categoryFamily, color: const Color(0xFFFFAA5E)),
    _Category(emoji: '✨', label: l10n.categoryFantasy, color: const Color(0xFF9B5DE5)),
    _Category(emoji: '🤝', label: l10n.categoryFriendship, color: const Color(0xFF06D6A0)),
    _Category(emoji: '🦁', label: l10n.categoryAnimal, color: const Color(0xFFFFD166)),
    _Category(emoji: '🌊', label: l10n.categorySea, color: const Color(0xFF118AB2)),
    _Category(emoji: '🚀', label: l10n.categorySpace, color: const Color(0xFF073B4C)),
    _Category(emoji: '🧙', label: l10n.categoryMagic, color: const Color(0xFFEF476F)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _buildCategories(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(title: l10n.createTitle),
          Container(
            width: double.infinity,
            color: AppColors.create,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? cat.color : AppColors.divider,
                          width: isSelected ? 0 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? cat.color.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: isSelected ? 12 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedCategory != null ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.create,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      _selectedCategory != null
                          ? l10n.createBtnWithCategory(
                              categories[_selectedCategory!].label)
                          : l10n.createBtnNoCategory,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
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

class _Category {
  final String emoji;
  final String label;
  final Color color;
  const _Category(
      {required this.emoji, required this.label, required this.color});
}
