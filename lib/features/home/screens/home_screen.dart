import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tags = [
    '#프렌치스타일', '#꽃', '#빵', '#개미', '#구름', '#딸기',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFDF5),
        body: Column(
          children: [
            // 상태바 영역
            Container(
              color: const Color(0xFFFE9EC7),
              height: MediaQuery.of(context).padding.top,
            ),
            // 앱바
            Container(
              color: const Color(0xFFFE9EC7),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.chevron_left,
                      color: Color(0xFF333333), size: 24),
                  const Spacer(),
                  const Text(
                    '모두의 동화제작소',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search,
                      color: Color(0xFF333333), size: 20),
                ],
              ),
            ),
            // 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _StoryTab(tags: _tags),
                  const Center(
                    child: Text(
                      '그림조각',
                      style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
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

class _StoryTab extends StatelessWidget {
  final List<String> tags;

  const _StoryTab({required this.tags});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그 행
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              itemCount: tags.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _TagChip(label: tags[i]),
            ),
          ),
          // 주제별 모음
          _SectionPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: '주제별 모음'),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _ThemeCard(
                        title: '여름은 인디머쉬',
                        tag: '#해변가',
                        color: Color(0xFF7EC8C8),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ThemeCard(
                        title: '애니메이션도',
                        tag: '#문학거리',
                        color: Color(0xFFE8A87C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 신규 출시 목록
          _SectionPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                    title: '신규 출시 목록', showMore: true),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    _newItems.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right:
                                i < _newItems.length - 1 ? 12 : 0),
                        child: _StoryCard(item: _newItems[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 추천 목록
          _SectionPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: '추천 목록', showMore: true),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    _recoItems.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: i < _recoItems.length - 1
                                ? 10
                                : 0),
                        child: _RecoCard(item: _recoItems[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── 공통 위젯 ───────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12, color: Color(0xFF333333)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showMore;

  const _SectionHeader({required this.title, this.showMore = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        if (showMore)
          const Text(
            '더보기',
            style: TextStyle(
                fontSize: 12, color: Color(0xFFAAAAAA)),
          ),
      ],
    );
  }
}

class _SectionPadding extends StatelessWidget {
  final Widget child;

  const _SectionPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: child,
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final String tag;
  final Color color;

  const _ThemeCard({
    required this.title,
    required this.tag,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(tag,
              style: const TextStyle(
                  fontSize: 10, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final _StoryItem item;

  const _StoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded,
                size: 11, color: Color(0xFFFFB300)),
            Text(
              item.rating.toStringAsFixed(1),
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF888888)),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecoCard extends StatelessWidget {
  final _RecoItem item;

  const _RecoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

// ─── 더미 데이터 ─────────────────────────────────────────────

class _StoryItem {
  final String title;
  final double rating;
  final Color color;

  const _StoryItem(
      {required this.title,
      required this.rating,
      required this.color});
}

class _RecoItem {
  final String title;
  final Color color;

  const _RecoItem({required this.title, required this.color});
}

const _newItems = [
  _StoryItem(
      title: '가마솥', rating: 5.0, color: Color(0xFFFFD6A5)),
  _StoryItem(
      title: '나무바닥', rating: 3.0, color: Color(0xFFA8D8EA)),
  _StoryItem(
      title: '울면서 도망가는...', rating: 5.0, color: Color(0xFFFFB7B2)),
  _StoryItem(
      title: '놀란 아기도', rating: 5.0, color: Color(0xFFB5EAD7)),
];

const _recoItems = [
  _RecoItem(title: '빨간 사과', color: Color(0xFFFFB7B2)),
  _RecoItem(title: '빵 만들기', color: Color(0xFFFFD6A5)),
  _RecoItem(title: '핫도그 파티', color: Color(0xFFA8D8EA)),
];
