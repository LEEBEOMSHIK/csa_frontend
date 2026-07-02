import 'package:flutter/material.dart';
import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_slide_screen.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/screens/fairytale_detail_screen.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/features/my/models/my_fairytale.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/utils/app_colors.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class FairytaleListScreen extends StatelessWidget {
  final MyFairytaleService? service;
  final DownloadManager? downloadManager;
  final CatalogService? catalogService;

  const FairytaleListScreen({
    super.key,
    this.service,
    this.downloadManager,
    this.catalogService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.library,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            l10n.fairytaleListTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: l10n.fairytaleTabClassic),
              Tab(text: l10n.fairytaleTabAi),
              Tab(text: l10n.fairytaleTabShared),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ClassicFairytaleGrid(
              service: catalogService ?? FairytaleService.instance,
            ),
            _FairytaleGrid(items: _aiTales),
            _SharedFairytaleGrid(
              service: service ?? MyFairytaleService.instance,
              downloadManager: downloadManager ?? DownloadManager.instance,
            ),
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
    final l10n = AppLocalizations.of(context)!;
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.18),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _VoiceBadge(
                              label: l10n.voiceDad,
                              badgeText: l10n.voiceBadge(l10n.voiceDad),
                              color: item.color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 12,
                            color: AppColors.favorites,
                          ),
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

class _ClassicFairytaleGrid extends StatefulWidget {
  final CatalogService service;

  const _ClassicFairytaleGrid({required this.service});

  @override
  State<_ClassicFairytaleGrid> createState() => _ClassicFairytaleGridState();
}

enum _ClassicSort { latest, rating, title }

class _ClassicFairytaleGridState extends State<_ClassicFairytaleGrid> {
  late Future<List<FairytaleItem>> _future;
  List<FairytaleCategory> _categories = [];
  String? _selectedCategory;
  _ClassicSort _selectedSort = _ClassicSort.latest;

  @override
  void initState() {
    super.initState();
    _future = _loadFairytales();
    _loadCategories();
  }

  @override
  void didUpdateWidget(covariant _ClassicFairytaleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      _categories = [];
      _selectedCategory = null;
      _selectedSort = _ClassicSort.latest;
      _future = _loadFairytales();
      _loadCategories();
    }
  }

  String? get _sortParam {
    switch (_selectedSort) {
      case _ClassicSort.rating:
        return 'rating';
      case _ClassicSort.title:
        return 'title';
      case _ClassicSort.latest:
        return null;
    }
  }

  Future<List<FairytaleItem>> _loadFairytales() {
    return widget.service.getFairytales(
      category: _selectedCategory,
      sort: _sortParam,
    );
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.service.getCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      // 카테고리 로드 실패 시 칩만 숨기고 목록 로드는 계속한다.
    }
  }

  void _reload() {
    setState(() => _future = _loadFairytales());
  }

  void _onCategoryTap(String? categoryKey) {
    final next = _selectedCategory == categoryKey ? null : categoryKey;
    setState(() {
      _selectedCategory = next;
      _future = _loadFairytales();
    });
  }

  void _onSortSelected(_ClassicSort sort) {
    if (sort == _selectedSort) return;
    setState(() {
      _selectedSort = sort;
      _future = _loadFairytales();
    });
  }

  String _sortLabel(AppLocalizations l10n, _ClassicSort sort) {
    switch (sort) {
      case _ClassicSort.rating:
        return l10n.fairytaleSortRating;
      case _ClassicSort.title:
        return l10n.fairytaleSortTitle;
      case _ClassicSort.latest:
        return l10n.fairytaleSortLatest;
    }
  }

  void _open(FairytaleItem item, String lang) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FairytaleDetailScreen(item: item, lang: lang),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = localeNotifier.value.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ClassicFilterHeader(
          l10n: l10n,
          lang: lang,
          categories: _categories,
          selectedCategory: _selectedCategory,
          selectedSort: _selectedSort,
          sortLabel: _sortLabel,
          onCategoryTap: _onCategoryTap,
          onSortSelected: _onSortSelected,
        ),
        Expanded(
          child: FutureBuilder<List<FairytaleItem>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.library),
                );
              }
              if (snapshot.hasError) {
                return _SharedStateView(
                  icon: Icons.cloud_off_rounded,
                  message: l10n.fairytaleListError,
                  retryLabel: l10n.fairytaleListRetry,
                  onRetry: _reload,
                );
              }
              final items = snapshot.data ?? const <FairytaleItem>[];
              if (items.isEmpty) {
                return _SharedStateView(
                  icon: Icons.auto_stories_outlined,
                  message: l10n.fairytaleListEmpty,
                );
              }
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
                  return _ClassicFairytaleCard(
                    item: item,
                    lang: lang,
                    onTap: () => _open(item, lang),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClassicFilterHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String lang;
  final List<FairytaleCategory> categories;
  final String? selectedCategory;
  final _ClassicSort selectedSort;
  final String Function(AppLocalizations, _ClassicSort) sortLabel;
  final ValueChanged<String?> onCategoryTap;
  final ValueChanged<_ClassicSort> onSortSelected;

  const _ClassicFilterHeader({
    required this.l10n,
    required this.lang,
    required this.categories,
    required this.selectedCategory,
    required this.selectedSort,
    required this.sortLabel,
    required this.onCategoryTap,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return _ClassicFilterChip(
                          label: l10n.fairytaleFilterAll,
                          selected: selectedCategory == null,
                          onTap: () => onCategoryTap(null),
                        );
                      }
                      final cat = categories[i - 1];
                      return _ClassicFilterChip(
                        label: '#${lang == 'ja' ? cat.nameJa : cat.nameKo}',
                        selected: selectedCategory == cat.categoryKey,
                        onTap: () => onCategoryTap(cat.categoryKey),
                      );
                    },
                  ),
                ),
              ),
              PopupMenuButton<_ClassicSort>(
                tooltip: l10n.fairytaleSortLabel,
                onSelected: onSortSelected,
                itemBuilder: (context) => _ClassicSort.values
                    .map(
                      (sort) => PopupMenuItem<_ClassicSort>(
                        value: sort,
                        child: Text(sortLabel(l10n, sort)),
                      ),
                    )
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sortLabel(l10n, selectedSort),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
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
    );
  }
}

class _ClassicFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ClassicFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
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

class _ClassicFairytaleCard extends StatelessWidget {
  final FairytaleItem item;
  final String lang;
  final VoidCallback onTap;

  const _ClassicFairytaleCard({
    required this.item,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _classicCardColor(item.colorHex);
    return GestureDetector(
      onTap: onTap,
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titleFor(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFFB300),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _classicCardColor(String? hex) {
  if (hex != null) {
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) {
      final parsed = int.tryParse('FF$value', radix: 16);
      if (parsed != null) return Color(parsed);
    }
  }
  return AppColors.library;
}

class _SharedFairytaleGrid extends StatefulWidget {
  final MyFairytaleService service;
  final DownloadManager downloadManager;

  const _SharedFairytaleGrid({
    required this.service,
    required this.downloadManager,
  });

  @override
  State<_SharedFairytaleGrid> createState() => _SharedFairytaleGridState();
}

class _SharedFairytaleGridState extends State<_SharedFairytaleGrid> {
  late Future<List<MyFairytale>> _future;
  final Set<int> _downloading = {};
  final Set<int> _cancelled = {};

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchSharedFairytales();
  }

  @override
  void didUpdateWidget(covariant _SharedFairytaleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      _future = widget.service.fetchSharedFairytales();
    }
  }

  void _reload() {
    setState(() => _future = widget.service.fetchSharedFairytales());
  }

  bool _isOffline(MyFairytale item) =>
      widget.downloadManager.isOfflineAvailable(item.id.toString());

  Future<void> _open(MyFairytale item) async {
    if (!item.isCompleted || item.format != 'slide') return;
    final l10n = AppLocalizations.of(context)!;

    final offline = widget.downloadManager.getSlide(item.id.toString());
    if (offline != null) {
      final response = FairytaleGenerateResponse.fromOfflineSlide(
        offline,
        language: item.language,
        voiceType: 'dad',
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FairytaleSlideScreen(
            fairytale: response,
            lang: item.language,
            voiceType: 'dad',
          ),
        ),
      );
      return;
    }

    try {
      final response = await widget.service.fetchSharedSlides(item.id);
      if (!mounted) return;
      if (response.pages.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ttsNoContent)));
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FairytaleSlideScreen(
            fairytale: response,
            lang: response.language.isNotEmpty
                ? response.language
                : item.language,
            voiceType: response.voiceType,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sharedFairytaleError)));
    }
  }

  Future<void> _saveOffline(MyFairytale item) async {
    if (!item.isCompleted || item.format != 'slide') return;
    final l10n = AppLocalizations.of(context)!;
    if (!isPremiumNotifier.value) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlinePremiumRequired)));
      return;
    }
    setState(() {
      _downloading.add(item.id);
      _cancelled.remove(item.id);
    });
    try {
      await widget.downloadManager.downloadSlide(
        fairytaleId: item.id,
        voiceType: 'dad',
        language: item.language,
        shared: true,
      );
      if (!mounted || _cancelled.contains(item.id)) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineSaveSuccess)));
    } catch (_) {
      if (!mounted || _cancelled.contains(item.id)) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineSaveFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _downloading.remove(item.id);
          _cancelled.remove(item.id);
        });
      }
    }
  }

  Future<void> _cancelOffline(MyFairytale item) async {
    if (!_downloading.contains(item.id)) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _cancelled.add(item.id));
    try {
      await widget.downloadManager.cancel(item.id.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineCancelSuccess)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _cancelled.remove(item.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineCancelFailed)));
    }
  }

  Future<void> _deleteOffline(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    await widget.downloadManager.delete(item.id.toString());
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.offlineDeleteSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<MyFairytale>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.library),
          );
        }
        if (snapshot.hasError) {
          return _SharedStateView(
            icon: Icons.cloud_off_rounded,
            message: l10n.sharedFairytaleError,
            retryLabel: l10n.sharedFairytaleRetry,
            onRetry: _reload,
          );
        }
        final items = snapshot.data ?? const <MyFairytale>[];
        if (items.isEmpty) {
          return _SharedStateView(
            icon: Icons.auto_stories_outlined,
            message: l10n.sharedFairytaleEmpty,
          );
        }
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
            return ValueListenableBuilder<bool>(
              valueListenable: isPremiumNotifier,
              builder: (_, isPremium, _) => _SharedFairytaleCard(
                item: item,
                l10n: l10n,
                isPremium: isPremium,
                isOffline: _isOffline(item),
                isDownloading: _downloading.contains(item.id),
                onOpen: () => _open(item),
                onSaveOffline: () => _saveOffline(item),
                onDeleteOffline: () => _deleteOffline(item),
                onCancelOffline: () => _cancelOffline(item),
              ),
            );
          },
        );
      },
    );
  }
}

class _SharedFairytaleCard extends StatelessWidget {
  final MyFairytale item;
  final AppLocalizations l10n;
  final bool isPremium;
  final bool isOffline;
  final bool isDownloading;
  final VoidCallback onOpen;
  final VoidCallback onSaveOffline;
  final VoidCallback onDeleteOffline;
  final VoidCallback onCancelOffline;

  const _SharedFairytaleCard({
    required this.item,
    required this.l10n,
    required this.isPremium,
    required this.isOffline,
    required this.isDownloading,
    required this.onOpen,
    required this.onSaveOffline,
    required this.onDeleteOffline,
    required this.onCancelOffline,
  });

  @override
  Widget build(BuildContext context) {
    final canOpen = item.isCompleted && item.format == 'slide';
    return GestureDetector(
      onTap: canOpen ? onOpen : null,
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
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _SharedThumbnail(item: item)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _SharedOfflineButton(
                      l10n: l10n,
                      isPremium: isPremium,
                      isOffline: isOffline,
                      isDownloading: isDownloading,
                      onSave: onSaveOffline,
                      onDelete: onDeleteOffline,
                      onCancel: onCancelOffline,
                    ),
                  ),
                ],
              ),
            ),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          l10n.myFairytalePageCount(item.pageCount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _VoiceBadge(
                    label: l10n.voiceDad,
                    badgeText: l10n.voiceBadge(l10n.voiceDad),
                    color: AppColors.library,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedThumbnail extends StatelessWidget {
  final MyFairytale item;

  const _SharedThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = item.thumbnailUrl;
    Widget placeholder() => Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFF4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: AppColors.library,
          size: 48,
        ),
      ),
    );

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return placeholder();
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Image.network(
        thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder(),
      ),
    );
  }
}

class _SharedOfflineButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isPremium;
  final bool isOffline;
  final bool isDownloading;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _SharedOfflineButton({
    required this.l10n,
    required this.isPremium,
    required this.isOffline,
    required this.isDownloading,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return _iconButton(
        tooltip: l10n.offlineCancelAction,
        onPressed: onCancel,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.library,
              ),
              Icon(Icons.close_rounded, size: 12, color: Color(0xFF777777)),
            ],
          ),
        ),
      );
    }
    if (isOffline) {
      return _iconButton(
        tooltip: l10n.offlineDeleteAction,
        onPressed: onDelete,
        icon: const Icon(Icons.offline_pin_rounded, color: AppColors.library),
      );
    }
    if (!isPremium) {
      return _iconButton(
        tooltip: l10n.offlineLockedAction,
        onPressed: onSave,
        icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF999999)),
      );
    }
    return _iconButton(
      tooltip: l10n.offlineSaveAction,
      onPressed: onSave,
      icon: const Icon(Icons.download_outlined, color: Color(0xFF777777)),
    );
  }

  Widget _iconButton({
    required String tooltip,
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: icon,
        iconSize: 20,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _SharedStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const _SharedStateView({
    required this.icon,
    required this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: const Color(0xFFDDDDDD)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null && retryLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text(retryLabel!)),
          ],
        ],
      ),
    );
  }
}

class _VoiceBadge extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color color;
  const _VoiceBadge({
    required this.label,
    required this.badgeText,
    required this.color,
  });

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
            badgeText,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
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

const List<_FairytaleItem> _aiTales = [
  _FairytaleItem(
    emoji: '🚀',
    title: '우주를 여행한 토끼',
    color: Color(0xFF073B4C),
    likes: 42,
  ),
  _FairytaleItem(
    emoji: '🦄',
    title: '무지개 유니콘의 모험',
    color: Color(0xFF9B5DE5),
    likes: 38,
  ),
  _FairytaleItem(
    emoji: '🌊',
    title: '바닷속 작은 물고기',
    color: Color(0xFF118AB2),
    likes: 29,
  ),
  _FairytaleItem(
    emoji: '🏔️',
    title: '산을 넘는 작은 곰',
    color: Color(0xFFFFAA5E),
    likes: 21,
  ),
];
