import 'package:flutter/material.dart';
import 'package:csa_frontend/features/favorites/services/favorite_service.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_detail.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class FairytaleDetailScreen extends StatefulWidget {
  final FairytaleItem item;
  final String lang;

  const FairytaleDetailScreen({
    super.key,
    required this.item,
    required this.lang,
  });

  @override
  State<FairytaleDetailScreen> createState() => _FairytaleDetailScreenState();
}

class _FairytaleDetailScreenState extends State<FairytaleDetailScreen> {
  FairytaleDetailData? _detail;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await FairytaleService.instance.getDetail(widget.item.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
    }
  }

  Color _categoryColor() {
    final cat =
        widget.item.categories.isNotEmpty ? widget.item.categories.first : '';
    const colors = <String, Color>{
      '모험': Color(0xFF6B8CFF),
      '가족': Color(0xFFFF8FAB),
      '판타지': Color(0xFF9C6FDE),
      '우정': Color(0xFFFFB347),
      '동물': Color(0xFF6BCB77),
      '바다': Color(0xFF4DB6E8),
      '우주': Color(0xFF5C5C9C),
      '마법': Color(0xFFB56CE2),
      '숲·자연': Color(0xFF4CAF50),
      '왕국·성': Color(0xFFFFD700),
      '학교': Color(0xFFFF7043),
      '도시·마을': Color(0xFF78909C),
    };
    return colors[cat] ?? const Color(0xFFFFA7A7);
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final current = List<FairytaleItem>.from(favoritesNotifier.value);
    final isFav = current.any((f) => f.id == widget.item.id);
    if (isFav) {
      current.removeWhere((f) => f.id == widget.item.id);
    } else {
      current.add(widget.item);
    }
    favoritesNotifier.value = current;
    try {
      if (isFav) {
        await FavoriteService.instance.removeFavorite(widget.item.id);
      } else {
        await FavoriteService.instance.addFavorite(widget.item.id);
      }
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFav ? l10n.detailFavoriteRemoved : l10n.detailFavoriteAdded),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroColor =
        _parseColor(widget.item.colorHex) ?? const Color(0xFF7EC8C8);

    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final title = widget.item.titleFor(lang);
        final description = widget.item.descriptionFor(lang);
        final categoryColor = _categoryColor();
        final categoryLabel = widget.item.categories.isNotEmpty
            ? widget.item.categories.first
            : '';

        return Scaffold(
          backgroundColor: const Color(0xFFFFFDF5),
          body: Column(
            children: [
              // UpperSection: hero image area with buttons
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: heroColor),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          height: MediaQuery.of(context).padding.top),
                    ),
                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    // Right action buttons
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 16,
                      child: Column(
                        children: [
                          _RoundIconBtn(
                            icon: Icons.auto_stories,
                            onTap: null,
                          ),
                          const SizedBox(height: 8),
                          _RoundIconBtn(
                            icon: Icons.play_circle,
                            onTap: null,
                          ),
                          const SizedBox(height: 8),
                          // Favorite button — toggles this fairy tale in the favorites list
                          ValueListenableBuilder<List<FairytaleItem>>(
                            valueListenable: favoritesNotifier,
                            builder: (context, favorites, _) {
                              final isFav = favorites.any((f) => f.id == widget.item.id);
                              return GestureDetector(
                                onTap: () => _toggleFavorite(context),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isFav
                                        ? const Color(0xFFFF4D6D).withValues(alpha: 0.85)
                                        : Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // LowerSection: content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        if (widget.item.themeTag != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.item.themeTag!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                        if (widget.item.rating != null) ...[
                          const SizedBox(height: 8),
                          _RatingRow(rating: widget.item.rating!),
                        ],
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 12),
                        // Category chips
                        if (widget.item.categories.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.item.categories
                                .map((c) => _TagChip(label: '#$c'))
                                .toList(),
                          ),
                        if (description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF555555),
                              height: 1.6,
                            ),
                          ),
                        ],
                        // Detail info section (author, age, duration, pages — with icons)
                        if (_loadingDetail) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFE9EC7),
                              ),
                            ),
                          ),
                        ] else if (_detail != null) ...[
                          const SizedBox(height: 16),
                          _DetailInfoRow(
                              detail: _detail!, lang: lang, l10n: l10n),
                          if (_detail!.fullContentFor(lang) != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _detail!.fullContentFor(lang)!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                                height: 1.8,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        // OfflineSaveSection
                        const _OfflineSaveSection(),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        // Read button — styled by fairy tale category
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.menu_book_outlined,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  categoryLabel.isNotEmpty
                                      ? '$categoryLabel · ${l10n.detailReadBtn}'
                                      : l10n.detailReadBtn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Detail info row with icons
// ─────────────────────────────────────────────

class _DetailInfoRow extends StatelessWidget {
  final FairytaleDetailData detail;
  final String lang;
  final AppLocalizations l10n;

  const _DetailInfoRow({
    required this.detail,
    required this.lang,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            label: l10n.detailAuthorLabel,
            value: detail.authorFor(lang),
            icon: Icons.person_outline,
            iconColor: const Color(0xFF9C6FDE),
          ),
          _InfoChip(
            label: l10n.detailAgeLabel,
            value: detail.ageRange,
            icon: Icons.face_outlined,
            iconColor: const Color(0xFF7EC8C8),
          ),
          _InfoChip(
            label: l10n.detailDurationLabel,
            value: '${detail.durationMin}${l10n.detailMinUnit}',
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFFFFB74D),
          ),
          _InfoChip(
            label: l10n.detailPageUnit,
            value: '${detail.pageCount}p',
            icon: Icons.menu_book_outlined,
            iconColor: const Color(0xFFFFA7A7),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Offline Save Section
// ─────────────────────────────────────────────

class _OfflineSaveSection extends StatelessWidget {
  const _OfflineSaveSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.download_outlined,
                size: 16, color: Color(0xFF888888)),
            const SizedBox(width: 6),
            Text(
              l10n.detailOfflineSave,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const _DownloadModal(),
          ),
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save_alt_outlined,
                    size: 18, color: Color(0xFF7EC8C8)),
                const SizedBox(width: 8),
                Text(
                  l10n.detailDownloadSaveBtn,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Download Modal (Screen/DownloadModal)
// ─────────────────────────────────────────────

enum _DownloadFormat { slide, video }

class _DownloadModal extends StatefulWidget {
  const _DownloadModal();

  @override
  State<_DownloadModal> createState() => _DownloadModalState();
}

class _DownloadModalState extends State<_DownloadModal> {
  _DownloadFormat _selected = _DownloadFormat.slide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.detailDownloadModalTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.detailDownloadSubtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 16),
          // Slide format
          _FormatOption(
            icon: Icons.menu_book_outlined,
            iconBg: const Color(0xFFFFF0F0),
            iconColor: const Color(0xFFFFA7A7),
            title: l10n.detailDownloadSlide,
            desc: l10n.detailDownloadSlideDesc,
            size: '약 8.2 MB',
            selected: _selected == _DownloadFormat.slide,
            onTap: () => setState(() => _selected = _DownloadFormat.slide),
          ),
          const SizedBox(height: 10),
          // Video format
          _FormatOption(
            icon: Icons.play_circle_outline,
            iconBg: const Color(0xFFE8F4FD),
            iconColor: const Color(0xFF4DB6E8),
            title: l10n.detailDownloadVideo,
            desc: l10n.detailDownloadVideoDesc,
            size: '약 45.7 MB',
            selected: _selected == _DownloadFormat.video,
            onTap: () => setState(() => _selected = _DownloadFormat.video),
          ),
          const SizedBox(height: 20),
          // Cancel button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_outlined,
                      size: 18, color: Color(0xFF888888)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.detailDownloadCancel,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF555555)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String desc;
  final String size;
  final bool selected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF5F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFA7A7)
                : const Color(0xFFEEEEEE),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    size,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: selected
                  ? const Color(0xFFFFA7A7)
                  : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────

class _RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    return Row(
      children: [
        ...List.generate(
            5,
            (i) => Icon(
                  i < full
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: const Color(0xFFFFB300),
                )),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style:
              const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}

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
          fontSize: 12,
          color: Color(0xFF333333),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

Color? _parseColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value != null ? Color(value) : null;
}
