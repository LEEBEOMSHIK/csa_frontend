import 'package:flutter/material.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/app_colors.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<List<FairytaleItem>>(
      valueListenable: favoritesNotifier,
      builder: (context, items, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppTopBar(
                title: l10n.favoritesTitle,
                actions: [
                  if (items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.favoritesCountBadge(items.length),
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: items.isEmpty
                    ? _buildEmpty(context, l10n)
                    : _buildList(context, items),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            l10n.favoritesEmpty,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.favoritesEmptyDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.favorites,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(l10n.favoritesGoBtn,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<FairytaleItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemColor = _parseColor(item.colorHex);
        final categoryLabel =
            item.categories.isNotEmpty ? item.categories.first : '';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.auto_stories_rounded,
                  color: itemColor, size: 28),
            ),
            title: Text(
              item.titleFor(localeNotifier.value.languageCode),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: categoryLabel.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: itemColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: itemColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            trailing: GestureDetector(
              onTap: () {
                final current =
                    List<FairytaleItem>.from(favoritesNotifier.value);
                current.removeWhere((f) => f.id == item.id);
                favoritesNotifier.value = current;
              },
              child: const Icon(Icons.favorite_rounded,
                  color: AppColors.favorites, size: 22),
            ),
          ),
        );
      },
    );
  }
}

Color _parseColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) {
    return const Color(0xFFFFA7A7);
  }
  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value != null ? Color(value) : const Color(0xFFFFA7A7);
}
