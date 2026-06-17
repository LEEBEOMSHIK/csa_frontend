import 'dart:io';

import 'package:flutter/material.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_slide_screen.dart';
import 'package:csa_frontend/features/offline/models/offline_meta_entry.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/byte_format.dart';

/// 위치 D — 마이 페이지 오프라인 저장 동화 관리 화면.
/// 저장된(완료·미만료) 슬라이드 동화 목록을 보여주고 개별/전체 삭제를 제공한다.
class OfflineStorageScreen extends StatefulWidget {
  final DownloadManager? downloadManager;

  const OfflineStorageScreen({super.key, this.downloadManager});

  @override
  State<OfflineStorageScreen> createState() => _OfflineStorageScreenState();
}

class _OfflineStorageScreenState extends State<OfflineStorageScreen> {
  static const _accent = Color(0xFFFE9EC7);

  DownloadManager get _downloadManager =>
      widget.downloadManager ?? DownloadManager.instance;

  late List<_OfflineItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _loadItems();
  }

  List<_OfflineItem> _loadItems() {
    final metas = _downloadManager.availableMeta();
    final result = <_OfflineItem>[];
    for (final meta in metas) {
      final slide = _downloadManager.getSlide(meta.fairytaleId);
      if (slide == null) continue;
      result.add(_OfflineItem(meta: meta, slide: slide));
    }
    return result;
  }

  void _refresh() {
    setState(() => _items = _loadItems());
  }

  Future<void> _onDeleteOne(_OfflineItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.offlineStorageDeleteOneTitle,
      message: l10n.offlineStorageDeleteOneMessage,
      confirmLabel: l10n.offlineStorageDeleteOne,
    );
    if (confirmed != true) return;
    await _downloadManager.delete(item.meta.fairytaleId);
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.offlineDeleteSuccess)));
  }

  Future<void> _onDeleteAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.offlineStorageDeleteAllTitle,
      message: l10n.offlineStorageDeleteAllMessage,
      confirmLabel: l10n.offlineStorageDeleteAll,
    );
    if (confirmed != true) return;
    await _downloadManager.deleteAll();
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.offlineStorageDeleteAllDone)));
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.offlineStorageCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onOpen(_OfflineItem item) async {
    final restored = restoreOfflineVoiceLang(item.slide);
    final response = FairytaleGenerateResponse.fromOfflineSlide(
      item.slide,
      language: restored.language,
      voiceType: restored.voiceType,
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FairytaleSlideScreen(
          fairytale: response,
          lang: restored.language,
          voiceType: restored.voiceType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.offlineStorageManageTitle),
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.offlineStorageSummary(
                        _items.length,
                        formatBytes(_downloadManager.totalUsedBytes()),
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _onDeleteAll,
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: Text(
                      l10n.offlineStorageDeleteAll,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? _EmptyView(message: l10n.offlineStorageEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OfflineCard(
                      item: _items[i],
                      accent: _accent,
                      l10n: l10n,
                      onOpen: () => _onOpen(_items[i]),
                      onDelete: () => _onDeleteOne(_items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfflineItem {
  final OfflineMetaEntry meta;
  final OfflineSlideEntry slide;
  const _OfflineItem({required this.meta, required this.slide});
}

/// 저장된 오디오 키(`'${voiceType}_$language'`)에서 voice/language를 복원한다.
/// 키가 없으면 합리적 기본값('dad'/'ko')으로 폴백한다.
({String voiceType, String language}) restoreOfflineVoiceLang(
  OfflineSlideEntry slide,
) {
  for (final page in slide.pages) {
    if (page.localAudioPaths.isEmpty) continue;
    final key = page.localAudioPaths.keys.first;
    final sep = key.lastIndexOf('_');
    if (sep > 0 && sep < key.length - 1) {
      return (
        voiceType: key.substring(0, sep),
        language: key.substring(sep + 1),
      );
    }
  }
  return (voiceType: 'dad', language: 'ko');
}

class _OfflineCard extends StatelessWidget {
  final _OfflineItem item;
  final Color accent;
  final AppLocalizations l10n;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _OfflineCard({
    required this.item,
    required this.accent,
    required this.l10n,
    required this.onOpen,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.meta.fairytaleId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        // 삭제 흐름은 onDelete 내부 확인 다이얼로그가 담당하므로
        // Dismissible 자체 애니메이션은 막고 목록 갱신에 맡긴다.
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      child: GestureDetector(
        onTap: onOpen,
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
              _Thumbnail(path: item.slide.thumbnailLocalPath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.slide.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.sd_storage_rounded,
                          size: 13,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatBytes(item.meta.totalSizeBytes),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n.offlineStorageSavedAt(
                              _formatDate(item.meta.downloadedAt),
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.offlineStorageDeleteOne,
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
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String path;
  const _Thumbnail({required this.path});

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

    if (path.isEmpty || !File(path).existsSync()) {
      return placeholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder(),
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
            Icons.cloud_done_outlined,
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
