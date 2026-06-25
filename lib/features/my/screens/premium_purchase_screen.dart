import 'package:flutter/material.dart';

import 'package:csa_frontend/features/my/services/premium_purchase_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class PremiumPurchaseScreen extends StatefulWidget {
  final PremiumPurchaseService service;

  PremiumPurchaseScreen({super.key, PremiumPurchaseService? service})
    : service = service ?? PremiumPurchaseService.instance;

  @override
  State<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends State<PremiumPurchaseScreen> {
  PremiumProduct? _product;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.service.ensureListening();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await widget.service.loadPremiumProduct();
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final failedMessage = AppLocalizations.of(context)!.premiumPurchaseFailed;
      setState(() {
        _loading = false;
      });
      _showMessage(failedMessage);
    }
  }

  Future<void> _buyPremium() async {
    final l10n = AppLocalizations.of(context)!;
    final product = _product;
    if (product == null) {
      _showMessage(l10n.premiumProductNotFound);
      return;
    }
    await _runBusy(() async {
      await widget.service.buyPremium(product);
      _showMessage(l10n.premiumPurchaseStarted);
    }, l10n.premiumPurchaseFailed);
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context)!;
    await _runBusy(() async {
      await widget.service.restorePurchases();
      _showMessage(l10n.premiumRestoreStarted);
    }, l10n.premiumPurchaseFailed);
  }

  Future<void> _runBusy(
    Future<void> Function() action,
    String failedMessage,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      _showMessage(failedMessage);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.premiumTitle),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: isPremiumNotifier,
              builder: (context, isPremium, _) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _StatusBlock(
                      title: isPremium
                          ? l10n.premiumActiveTitle
                          : l10n.premiumFreeTitle,
                      subtitle: isPremium
                          ? l10n.premiumActiveSubtitle
                          : l10n.premiumFreeSubtitle,
                      icon: isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.lock_open_rounded,
                      color: isPremium
                          ? const Color(0xFF4A90D9)
                          : const Color(0xFF777777),
                    ),
                    const SizedBox(height: 16),
                    _PlanBlock(
                      title: l10n.premiumPlanTitle,
                      price: _loading
                          ? l10n.premiumLoading
                          : (_product?.price ?? l10n.premiumUnavailable),
                      description: _product?.title ?? l10n.premiumProductName,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _busy || _loading || _product == null
                          ? null
                          : _buyPremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90D9),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.premiumStartButton),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _busy ? null : _restorePurchases,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90D9),
                        side: const BorderSide(color: Color(0xFF4A90D9)),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.premiumRestoreButton),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatusBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    height: 1.4,
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

class _PlanBlock extends StatelessWidget {
  final String title;
  final String price;
  final String description;

  const _PlanBlock({
    required this.title,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A90D9),
            ),
          ),
        ],
      ),
    );
  }
}
