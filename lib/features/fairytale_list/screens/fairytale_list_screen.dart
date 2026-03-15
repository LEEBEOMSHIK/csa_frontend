import 'package:flutter/material.dart';
import 'package:csa_frontend/utils/app_colors.dart';

class FairytaleListScreen extends StatelessWidget {
  const FairytaleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.library,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            '기본 동화',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: '📚 유명 동화'),
              Tab(text: '🤖 AI 동화'),
              Tab(text: '🌟 공유 동화'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FairytaleGrid(items: _classicTales),
            _FairytaleGrid(items: _aiTales),
            _FairytaleGrid(items: _sharedTales),
          ],
        ),
      ),
    );
  }
}

class _FairytaleGrid extends StatelessWidget {
  final List<_FairytaleItem> items;
  const _FairytaleGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 표지 영역
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.18),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 4),
                        // 목소리 선택 아이콘
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _VoiceBadge(label: '아빠', color: item.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 제목 영역
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 12, color: AppColors.favorites),
                          const SizedBox(width: 3),
                          Text(
                            '${item.likes}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VoiceBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _VoiceBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.record_voice_over_rounded, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '$label 목소리',
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FairytaleItem {
  final String emoji;
  final String title;
  final Color color;
  final int likes;
  const _FairytaleItem({
    required this.emoji,
    required this.title,
    required this.color,
    required this.likes,
  });
}

const List<_FairytaleItem> _classicTales = [
  _FairytaleItem(emoji: '👸', title: '신데렐라', color: Color(0xFF9B5DE5), likes: 128),
  _FairytaleItem(emoji: '🍎', title: '백설공주', color: Color(0xFFEF476F), likes: 95),
  _FairytaleItem(emoji: '🐺', title: '빨간 모자', color: Color(0xFFFF6B6B), likes: 87),
  _FairytaleItem(emoji: '🦢', title: '미운 오리 새끼', color: Color(0xFF118AB2), likes: 74),
  _FairytaleItem(emoji: '🧱', title: '아기 돼지 삼형제', color: Color(0xFFFFAA5E), likes: 110),
  _FairytaleItem(emoji: '🌹', title: '잠자는 숲속의 공주', color: Color(0xFF06D6A0), likes: 66),
];

const List<_FairytaleItem> _aiTales = [
  _FairytaleItem(emoji: '🚀', title: '우주를 여행한 토끼', color: Color(0xFF073B4C), likes: 42),
  _FairytaleItem(emoji: '🦄', title: '무지개 유니콘의 모험', color: Color(0xFF9B5DE5), likes: 38),
  _FairytaleItem(emoji: '🌊', title: '바닷속 작은 물고기', color: Color(0xFF118AB2), likes: 29),
  _FairytaleItem(emoji: '🏔️', title: '산을 넘는 작은 곰', color: Color(0xFFFFAA5E), likes: 21),
];

const List<_FairytaleItem> _sharedTales = [
  _FairytaleItem(emoji: '⭐', title: '별을 모으는 아이', color: Color(0xFFFFD166), likes: 15),
  _FairytaleItem(emoji: '🌻', title: '해바라기 마을 이야기', color: Color(0xFF06D6A0), likes: 11),
  _FairytaleItem(emoji: '🦋', title: '나비와 친구가 된 날', color: Color(0xFFEF476F), likes: 8),
];
