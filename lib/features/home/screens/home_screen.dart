import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/screens/fairytale_detail_screen.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFE9EC7),
            height: MediaQuery.of(context).padding.top,
          ),
          Container(
            color: const Color(0xFFFE9EC7),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.chevron_left,
                    color: Color(0xFF333333), size: 24),
                const Spacer(),
                Text(
                  l10n.homeTitle,
                  style: const TextStyle(
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
          Container(
            color: const Color(0xFFFE9EC7),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF333333),
              unselectedLabelColor: const Color(0xFF333333),
              indicatorColor: const Color(0xFF333333),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(text: l10n.homeTabStory),
                Tab(text: l10n.homeTabPicture),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _StoryTab(),
                Center(
                  child: Text(
                    l10n.homeTabPicture,
                    style: const TextStyle(
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

class _StoryTab extends StatefulWidget {
  const _StoryTab();

  @override
  State<_StoryTab> createState() => _StoryTabState();
}

class _StoryTabState extends State<_StoryTab> {
  List<FairytaleCategory> _categories = [];
  String? _selectedCategory;
  HomePageData? _homeData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll(null);
    localeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    _loadAll(_selectedCategory);
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Future<void> _loadAll(String? categoryKey) async {
    setState(() => _loading = true);
    final lang = localeNotifier.value.languageCode;
    try {
      final results = await Future.wait([
        if (_categories.isEmpty) FairytaleService.instance.getCategories(),
        FairytaleService.instance.getHomePage(
            categoryKey: categoryKey, lang: lang),
      ]);
      if (!mounted) return;
      setState(() {
        if (_categories.isEmpty) {
          _categories = results[0] as List<FairytaleCategory>;
        }
        _homeData = results.last as HomePageData;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onCategoryTap(String categoryKey) {
    final next = _selectedCategory == categoryKey ? null : categoryKey;
    setState(() => _selectedCategory = next);
    _loadAll(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading && _homeData == null) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFE9EC7)));
    }

    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final themes = _homeData?.themes ?? [];
        final newItems = _homeData?.newItems ?? [];
        final recommended = _homeData?.recommended ?? [];

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 태그
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      itemCount: _categories.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected =
                            _selectedCategory == cat.categoryKey;
                        return _TagChip(
                          label:
                              '#${lang == 'ja' ? cat.nameJa : cat.nameKo}',
                          selected: selected,
                          onTap: () => _onCategoryTap(cat.categoryKey),
                        );
                      },
                    ),
                  ),

                  // 테마 섹션
                  if (themes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _SectionHeader(title: l10n.homeSectionTheme),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 160,
                          viewportFraction: 0.42,
                          enableInfiniteScroll: false,
                          padEnds: false,
                          scrollPhysics:
                              const BouncingScrollPhysics(),
                        ),
                        items: themes
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10),
                                  child: _ThemeCard(
                                      item: item, lang: lang),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // 새로운 동화 섹션
                  if (newItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _SectionHeader(
                          title: l10n.homeSectionNew,
                          showMore: true,
                          moreLabel: l10n.homeMoreBtn),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 160,
                          viewportFraction: 0.42,
                          enableInfiniteScroll: false,
                          padEnds: false,
                          scrollPhysics:
                              const BouncingScrollPhysics(),
                        ),
                        items: newItems
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10),
                                  child: _StoryCard(
                                      item: item, lang: lang),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // 추천 동화 섹션
                  if (recommended.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _SectionHeader(
                          title: l10n.homeSectionReco,
                          showMore: true,
                          moreLabel: l10n.homeMoreBtn),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 160,
                          viewportFraction: 0.42,
                          enableInfiniteScroll: false,
                          padEnds: false,
                          scrollPhysics:
                              const BouncingScrollPhysics(),
                        ),
                        items: recommended
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10),
                                  child: _RecoCard(
                                      item: item, lang: lang),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_loading)
              const Positioned(
                top: 8,
                right: 16,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFFE9EC7)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFE9EC7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFFE9EC7)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xFF333333),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showMore;
  final String moreLabel;

  const _SectionHeader({
    required this.title,
    this.showMore = false,
    this.moreLabel = '',
  });

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
          Text(
            moreLabel,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
          ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final FairytaleItem item;
  final String lang;

  const _ThemeCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(item.colorHex) ?? const Color(0xFF7EC8C8);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FairytaleDetailScreen(item: item, lang: lang),
        ),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.themeTag != null)
                Text(
                  item.themeTag!,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white70),
                ),
              const SizedBox(height: 2),
              Text(
                item.titleFor(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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

class _StoryCard extends StatelessWidget {
  final FairytaleItem item;
  final String lang;
  const _StoryCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(item.colorHex) ?? const Color(0xFFFFD6A5);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FairytaleDetailScreen(item: item, lang: lang),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.titleFor(lang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (item.rating != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    size: 11, color: Color(0xFFFFB300)),
                Text(
                  item.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF888888)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecoCard extends StatelessWidget {
  final FairytaleItem item;
  final String lang;
  const _RecoCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(item.colorHex) ?? const Color(0xFFFFB7B2);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FairytaleDetailScreen(item: item, lang: lang),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.titleFor(lang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

Color? _parseColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value != null ? Color(value) : null;
}
