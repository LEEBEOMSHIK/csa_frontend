import 'package:flutter/material.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../utils/app_colors.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int _selectedPartIndex = 0;
  final List<int> _selectedVariants = [0, 0, 0, 0, 0, 0];

  static const List<_PartCategory> _parts = [
    _PartCategory(label: '머리형', emoji: '🟡', variants: ['🟡', '🟤', '⬜', '🟠']),
    _PartCategory(label: '눈', emoji: '👁️', variants: ['😊', '😄', '🥺', '😎']),
    _PartCategory(label: '코', emoji: '👃', variants: ['작은코', '보통코', '오뚝코', '귀여운코']),
    _PartCategory(label: '입', emoji: '😄', variants: ['😁', '🙂', '😊', '😆']),
    _PartCategory(label: '헤어', emoji: '💇', variants: ['단발', '긴머리', '곱슬', '빡빡이']),
    _PartCategory(label: '의상', emoji: '👕', variants: ['👕', '👗', '🥼', '🧥']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: '내 캐릭터',
            actions: [
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_alt_rounded,
                          color: Color(0xFF333333), size: 18),
                      SizedBox(width: 4),
                      Text(
                        '저장',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 캐릭터 미리보기
          Container(
            color: AppColors.character,
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24, top: 16),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CharacterPreview(selectedVariants: _selectedVariants),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 파츠 카테고리 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_parts.length, (index) {
                  final isSelected = _selectedPartIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPartIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.character
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _parts[index].label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 파츠 변형 선택
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_parts[_selectedPartIndex].label} 선택',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      _parts[_selectedPartIndex].variants.length,
                      (index) {
                        final isSelected =
                            _selectedVariants[_selectedPartIndex] == index;
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _selectedVariants[_selectedPartIndex] = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.character.withValues(alpha: 0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.character
                                    : AppColors.divider,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _parts[_selectedPartIndex].variants[index],
                                style: const TextStyle(fontSize: 28),
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

          // 새 캐릭터 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.character,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  '새 캐릭터 만들기',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPreview extends StatelessWidget {
  final List<int> selectedVariants;
  const _CharacterPreview({required this.selectedVariants});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const Text('😊', style: TextStyle(fontSize: 64)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '나만의 캐릭터',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PartCategory {
  final String label;
  final String emoji;
  final List<String> variants;
  const _PartCategory(
      {required this.label, required this.emoji, required this.variants});
}
