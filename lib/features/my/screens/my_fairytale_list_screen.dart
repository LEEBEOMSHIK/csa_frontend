import 'package:flutter/material.dart';
import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_slide_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/features/my/models/my_fairytale.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/services/connectivity_service.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class MyFairytaleListScreen extends StatefulWidget {
  final MyFairytaleService? service;
  final DownloadManager? downloadManager;
  final ConnectivityService? connectivity;

  const MyFairytaleListScreen({
    super.key,
    this.service,
    this.downloadManager,
    this.connectivity,
  });

  @override
  State<MyFairytaleListScreen> createState() => _MyFairytaleListScreenState();
}

class _MyFairytaleListScreenState extends State<MyFairytaleListScreen> {
  static const _accent = Color(0xFFFE9EC7);

  late Future<List<MyFairytale>> _future;
  List<MyFairytale> _items = [];

  /// 직전 로드가 오프라인 저장본 기반이었는지 여부
  bool _loadedOffline = false;

  /// 다운로드 진행 중인 동화 id 집합
  final Set<int> _downloading = {};

  MyFairytaleService get _service =>
      widget.service ?? MyFairytaleService.instance;

  DownloadManager get _downloadManager =>
      widget.downloadManager ?? DownloadManager.instance;

  ConnectivityService get _connectivity =>
      widget.connectivity ?? ConnectivityService.instance;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _connectivity.isOnline.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivity.isOnline.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    // 온라인 복귀 시 서버 목록으로, 오프라인 진입 시 저장본 목록으로 자동 전환한다.
    _reload();
  }

  /// 오프라인 저장본만 [MyFairytale] 카드 모델로 변환해 표시한다.
  List<MyFairytale> _offlineItems() {
    return _downloadManager
        .availableSlides()
        .map(_offlineToMyFairytale)
        .toList();
  }

  static MyFairytale _offlineToMyFairytale(OfflineSlideEntry entry) {
    return MyFairytale(
      id: int.tryParse(entry.fairytaleId) ?? 0,
      title: entry.title,
      format: 'slide',
      status: 'COMPLETED',
      language: 'ko',
      shared: false,
      thumbnailUrl: null,
      pageCount: entry.pages.length,
      createdAt: entry.downloadedAt,
    );
  }

  Future<List<MyFairytale>> _load() async {
    // 오프라인이면 서버 호출 없이 저장본만 표시한다.
    if (!_connectivity.isOnline.value) {
      _loadedOffline = true;
      _items = _offlineItems();
      return _items;
    }
    try {
      final items = await _service.fetchMyFairytales();
      _loadedOffline = false;
      _items = items;
      return items;
    } on ApiException catch (e) {
      // 네트워크 오류는 저장본으로 폴백하고, 그 외 서버 오류는 그대로 노출한다.
      if (e.type == ApiExceptionType.network ||
          e.type == ApiExceptionType.timeout) {
        _loadedOffline = true;
        _items = _offlineItems();
        return _items;
      }
      rethrow;
    }
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> _onToggleShare(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final shared = await _service.toggleShare(item.id);
      setState(() {
        final idx = _items.indexWhere((e) => e.id == item.id);
        if (idx != -1) _items[idx] = _items[idx].copyWith(shared: shared);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.myFairytaleError)));
    }
  }

  Future<void> _onDelete(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.myFairytaleDeleteTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(l10n.myFairytaleDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.myFairytaleCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.myFairytaleDelete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.delete(item.id);
      setState(() => _items.removeWhere((e) => e.id == item.id));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.myFairytaleError)));
    }
  }

  bool _isOffline(MyFairytale item) =>
      _downloadManager.isOfflineAvailable(item.id.toString());

  Future<void> _onSaveOffline(MyFairytale item) async {
    if (!item.isCompleted || item.format != 'slide') return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _downloading.add(item.id));
    try {
      await _downloadManager.downloadSlide(
        fairytaleId: item.id,
        voiceType: 'dad',
        language: item.language,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineSaveSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineSaveFailed)));
    } finally {
      if (mounted) setState(() => _downloading.remove(item.id));
    }
  }

  Future<void> _onDeleteOffline(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    await _downloadManager.delete(item.id.toString());
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.offlineDeleteSuccess)));
  }

  Future<void> _onOpen(MyFairytale item) async {
    if (!item.isCompleted || item.format != 'slide') return;
    final l10n = AppLocalizations.of(context)!;

    // 오프라인 저장본이 있으면 로컬 파일로 재생한다.
    final offline = _downloadManager.getSlide(item.id.toString());
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

    // 저장본이 없는데 오프라인이면 서버 재생 대신 안내한다(접근 가드).
    if (!_connectivity.isOnline.value) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineUnavailable)));
      return;
    }

    try {
      final response = await _service.fetchSlides(item.id);
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
      ).showSnackBar(SnackBar(content: Text(l10n.myFairytaleError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.myFairytaleTitle),
          ValueListenableBuilder<bool>(
            valueListenable: _connectivity.isOnline,
            builder: (_, online, _) =>
                online ? const SizedBox.shrink() : _OfflineBanner(l10n: l10n),
          ),
          Expanded(
            child: FutureBuilder<List<MyFairytale>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accent),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorView(
                    message: l10n.myFairytaleError,
                    retryLabel: l10n.myFairytaleRetry,
                    onRetry: _reload,
                  );
                }
                if (_items.isEmpty) {
                  return _EmptyView(
                    message: _loadedOffline
                        ? l10n.offlineListEmpty
                        : l10n.myFairytaleEmpty,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _FairytaleCard(
                    item: _items[i],
                    accent: _accent,
                    l10n: l10n,
                    isOffline: _isOffline(_items[i]),
                    isDownloading: _downloading.contains(_items[i].id),
                    onOpen: () => _onOpen(_items[i]),
                    onToggleShare: () => _onToggleShare(_items[i]),
                    onDelete: () => _onDelete(_items[i]),
                    onSaveOffline: () => _onSaveOffline(_items[i]),
                    onDeleteOffline: () => _onDeleteOffline(_items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FairytaleCard extends StatelessWidget {
  final MyFairytale item;
  final Color accent;
  final AppLocalizations l10n;
  final bool isOffline;
  final bool isDownloading;
  final VoidCallback onOpen;
  final VoidCallback onToggleShare;
  final VoidCallback onDelete;
  final VoidCallback onSaveOffline;
  final VoidCallback onDeleteOffline;

  const _FairytaleCard({
    required this.item,
    required this.accent,
    required this.l10n,
    required this.isOffline,
    required this.isDownloading,
    required this.onOpen,
    required this.onToggleShare,
    required this.onDelete,
    required this.onSaveOffline,
    required this.onDeleteOffline,
  });

  @override
  Widget build(BuildContext context) {
    final canOpen = item.isCompleted && item.format == 'slide';
    return GestureDetector(
      onTap: canOpen ? onOpen : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _Thumbnail(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        item.format == 'video'
                            ? Icons.movie_rounded
                            : Icons.menu_book_rounded,
                        size: 14,
                        color: const Color(0xFF999999),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.myFairytalePageCount(item.pageCount),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(item: item, l10n: l10n),
                    ],
                  ),
                ],
              ),
            ),
            if (item.isCompleted && item.format == 'slide')
              _OfflineButton(
                l10n: l10n,
                accent: accent,
                isOffline: isOffline,
                isDownloading: isDownloading,
                onSave: onSaveOffline,
                onDelete: onDeleteOffline,
              ),
            if (item.isCompleted)
              IconButton(
                tooltip: item.shared
                    ? l10n.myFairytaleUnshare
                    : l10n.myFairytaleShare,
                onPressed: onToggleShare,
                icon: Icon(
                  item.shared ? Icons.public_rounded : Icons.public_off_rounded,
                  color: item.shared ? accent : const Color(0xFFBBBBBB),
                  size: 22,
                ),
              ),
            IconButton(
              tooltip: l10n.myFairytaleDelete,
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFBBBBBB),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineButton extends StatelessWidget {
  final AppLocalizations l10n;
  final Color accent;
  final bool isOffline;
  final bool isDownloading;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _OfflineButton({
    required this.l10n,
    required this.accent,
    required this.isOffline,
    required this.isDownloading,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return IconButton(
        tooltip: l10n.offlineDownloading,
        onPressed: null,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (isOffline) {
      return IconButton(
        tooltip: l10n.offlineDeleteAction,
        onPressed: onDelete,
        icon: Icon(Icons.offline_pin_rounded, color: accent, size: 22),
      );
    }
    return IconButton(
      tooltip: l10n.offlineSaveAction,
      onPressed: onSave,
      icon: const Icon(
        Icons.download_outlined,
        color: Color(0xFFBBBBBB),
        size: 22,
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _OfflineBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF1D6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: Color(0xFFB8860B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineBanner,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A6D1B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final MyFairytale item;
  const _Thumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    Widget placeholder() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.auto_stories_rounded,
        color: Color(0xFFCCCCCC),
        size: 24,
      ),
    );

    if (item.thumbnailUrl == null || item.thumbnailUrl!.isEmpty) {
      return placeholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        item.thumbnailUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder(),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MyFairytale item;
  final AppLocalizations l10n;
  const _StatusBadge({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (item.isCompleted) {
      // 완성 상태는 공유 여부만 칩으로 표시
      final shared = item.shared;
      return _chip(
        shared ? l10n.myFairytaleShared : l10n.myFairytalePrivate,
        shared ? const Color(0xFF2DC653) : const Color(0xFFAAAAAA),
      );
    }
    if (item.status == 'GENERATING') {
      return _chip(l10n.myFairytaleStatusGenerating, const Color(0xFFFFAA5E));
    }
    return _chip(l10n.myFairytaleStatusFailed, const Color(0xFFFF6B6B));
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 56,
            color: Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
