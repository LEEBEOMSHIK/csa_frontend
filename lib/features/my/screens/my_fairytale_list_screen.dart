import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/features/my/models/my_fairytale.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class MyFairytaleListScreen extends StatefulWidget {
  const MyFairytaleListScreen({super.key});

  @override
  State<MyFairytaleListScreen> createState() => _MyFairytaleListScreenState();
}

class _MyFairytaleListScreenState extends State<MyFairytaleListScreen> {
  static const _accent = Color(0xFFFE9EC7);

  late Future<List<MyFairytale>> _future;
  List<MyFairytale> _items = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<MyFairytale>> _load() async {
    final items = await MyFairytaleService.instance.fetchMyFairytales();
    _items = items;
    return items;
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> _onToggleShare(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final shared = await MyFairytaleService.instance.toggleShare(item.id);
      setState(() {
        final idx = _items.indexWhere((e) => e.id == item.id);
        if (idx != -1) _items[idx] = _items[idx].copyWith(shared: shared);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.myFairytaleError)));
    }
  }

  Future<void> _onDelete(MyFairytale item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.myFairytaleDeleteTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l10n.myFairytaleDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.myFairytaleCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.myFairytaleDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await MyFairytaleService.instance.delete(item.id);
      setState(() => _items.removeWhere((e) => e.id == item.id));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.myFairytaleError)));
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
                  return _EmptyView(message: l10n.myFairytaleEmpty);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _FairytaleCard(
                    item: _items[i],
                    accent: _accent,
                    l10n: l10n,
                    onToggleShare: () => _onToggleShare(_items[i]),
                    onDelete: () => _onDelete(_items[i]),
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
  final VoidCallback onToggleShare;
  final VoidCallback onDelete;

  const _FairytaleCard({
    required this.item,
    required this.accent,
    required this.l10n,
    required this.onToggleShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (item.isCompleted)
            IconButton(
              tooltip:
                  item.shared ? l10n.myFairytaleUnshare : l10n.myFairytaleShare,
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
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFBBBBBB), size: 22),
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
          child: const Icon(Icons.auto_stories_rounded,
              color: Color(0xFFCCCCCC), size: 24),
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
          const Icon(Icons.auto_stories_outlined,
              size: 56, color: Color(0xFFDDDDDD)),
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
          const Icon(Icons.cloud_off_rounded,
              size: 48, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
