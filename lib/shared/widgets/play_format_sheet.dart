import 'package:flutter/material.dart';

import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/app_colors.dart';

/// 재생 형식 선택 결과.
enum PlayFormat { slide, video }

/// 재생 시작 전 슬라이드/영상 중 하나를 고르게 한다.
/// 사용자가 시트를 닫으면 null을 반환한다.
Future<PlayFormat?> showPlayFormatSheet(BuildContext context) {
  return showModalBottomSheet<PlayFormat>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => PlayFormatSheet(
      onSelect: (format) => Navigator.of(sheetContext).pop(format),
    ),
  );
}

class PlayFormatSheet extends StatelessWidget {
  final ValueChanged<PlayFormat> onSelect;

  const PlayFormatSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l10n.playFormatTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _PlayFormatCard(
            key: const Key('play-format-slide'),
            emoji: '📖',
            label: l10n.detailDownloadSlide,
            desc: l10n.detailDownloadSlideDesc,
            color: const Color(0xFF5BBFAB),
            onTap: () => onSelect(PlayFormat.slide),
          ),
          const SizedBox(height: 12),
          _PlayFormatCard(
            key: const Key('play-format-video'),
            emoji: '🎬',
            label: l10n.detailDownloadVideo,
            desc: l10n.detailDownloadVideoDesc,
            color: const Color(0xFF9B5DE5),
            onTap: () => onSelect(PlayFormat.video),
          ),
        ],
      ),
    );
  }
}

class _PlayFormatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _PlayFormatCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
