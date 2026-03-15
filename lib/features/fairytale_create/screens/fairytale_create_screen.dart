import 'package:flutter/material.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/app_colors.dart';

class FairytaleCreateScreen extends StatefulWidget {
  const FairytaleCreateScreen({super.key});

  @override
  State<FairytaleCreateScreen> createState() => _FairytaleCreateScreenState();
}

class _FairytaleCreateScreenState extends State<FairytaleCreateScreen> {
  int? _selectedCategory;

  static const List<_Category> _categories = [
    _Category(emoji: '🏰', label: '모험', color: Color(0xFFFF6B6B)),
    _Category(emoji: '👨‍👩‍👧', label: '가족', color: Color(0xFFFFAA5E)),
    _Category(emoji: '✨', label: '판타지', color: Color(0xFF9B5DE5)),
    _Category(emoji: '🤝', label: '우정', color: Color(0xFF06D6A0)),
    _Category(emoji: '🦁', label: '동물', color: Color(0xFFFFD166)),
    _Category(emoji: '🌊', label: '바다', color: Color(0xFF118AB2)),
    _Category(emoji: '🚀', label: '우주', color: Color(0xFF073B4C)),
    _Category(emoji: '🧙', label: '마법', color: Color(0xFFEF476F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppTopBar(title: '동화 만들기'),
          // 헤더 배너
          Container(
            width: double.infinity,
            color: AppColors.create,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '어떤 동화를 만들까요? 📖',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '카테고리를 선택하면 AI가 특별한 동화를 만들어줘요!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
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
                          Text(cat.emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
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

          // 동화 만들기 버튼
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      _selectedCategory != null
                          ? '${_categories[_selectedCategory!].label} 동화 만들기!'
                          : '카테고리를 먼저 선택해주세요',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
  const _Category({required this.emoji, required this.label, required this.color});
}
