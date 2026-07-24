import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/screens/admin_fairytale_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_report_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_subscription_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_user_list_screen.dart';
import 'package:csa_frontend/features/admin/services/admin_fairytale_service.dart';
import 'package:csa_frontend/features/admin/services/admin_report_service.dart';
import 'package:csa_frontend/features/admin/services/admin_subscription_service.dart';
import 'package:csa_frontend/features/admin/services/admin_user_service.dart';
import 'package:csa_frontend/features/admin/widgets/admin_nav_bar.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _loading = true;
  int? _userCount;
  int? _fairytaleCount;
  int? _subscriptionCount;
  int? _reportCount;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _safeTotal(
        () async =>
            (await AdminUserService.instance.fetchUsers(page: 0, size: 1))
                .totalElements,
      ),
      _safeTotal(
        () async => (await AdminFairytaleService.instance.fetchFairytales(
          page: 0,
          size: 1,
        )).totalElements,
      ),
      _safeTotal(
        () async => (await AdminSubscriptionService.instance
                .fetchSubscriptions(status: 'ACTIVE', page: 0, size: 1))
            .totalElements,
      ),
      _safeTotal(
        () async =>
            (await AdminReportService.instance.fetchReports(page: 0, size: 1))
                .totalElements,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _userCount = results[0];
      _fairytaleCount = results[1];
      _subscriptionCount = results[2];
      _reportCount = results[3];
      _loading = false;
    });
  }

  Future<int?> _safeTotal(Future<int> Function() request) async {
    try {
      return await request();
    } catch (_) {
      return null;
    }
  }

  void _openUsers() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
  );

  void _openFairytales() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AdminFairytaleListScreen()),
  );

  void _openSubscriptions() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AdminSubscriptionListScreen()),
  );

  void _openReports() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AdminReportListScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          const AdminNavBar(current: AdminSection.dashboard),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 900
                        ? 4
                        : (constraints.maxWidth >= 480 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.6,
                      children: [
                        _StatCard(
                          icon: Icons.people_alt_rounded,
                          label: l10n.adminDashboardTotalUsers,
                          value: _userCount,
                          loading: _loading,
                          color: const Color(0xFF4A90D9),
                          onTap: _openUsers,
                        ),
                        _StatCard(
                          icon: Icons.auto_stories_rounded,
                          label: l10n.adminDashboardTotalFairytales,
                          value: _fairytaleCount,
                          loading: _loading,
                          color: const Color(0xFF06D6A0),
                          onTap: _openFairytales,
                        ),
                        _StatCard(
                          icon: Icons.workspace_premium_rounded,
                          label: l10n.adminDashboardActiveSubscriptions,
                          value: _subscriptionCount,
                          loading: _loading,
                          color: const Color(0xFF9B5DE5),
                          onTap: _openSubscriptions,
                        ),
                        _StatCard(
                          icon: Icons.flag_rounded,
                          label: l10n.adminDashboardPendingReports,
                          value: _reportCount,
                          loading: _loading,
                          color: const Color(0xFFFF6B6B),
                          highlighted: true,
                          onTap: _openReports,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? value;
  final bool loading;
  final Color color;
  final bool highlighted;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.loading,
    required this.color,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = highlighted ? color.withValues(alpha: 0.10) : Colors.white;
    final borderColor = highlighted
        ? color.withValues(alpha: 0.45)
        : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 26),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (loading)
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else if (value == null)
              Tooltip(
                message: l10n.adminDashboardLoadFailed,
                child: const Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFAAAAAA),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '-',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
