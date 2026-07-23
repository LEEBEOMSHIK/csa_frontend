import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:csa_frontend/features/admin/screens/admin_fairytale_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_login_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_report_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_subscription_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_user_list_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(
            title: l10n.adminMenuTitle,
            actions: [
              IconButton(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Color(0xFF333333)),
                tooltip: l10n.adminLogout,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _AdminMenuRow(
                  icon: Icons.people_alt_rounded,
                  label: l10n.adminUsersTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminUserListScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                _AdminMenuRow(
                  icon: Icons.auto_stories_rounded,
                  label: l10n.adminFairytalesTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminFairytaleListScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                _AdminMenuRow(
                  icon: Icons.workspace_premium_rounded,
                  label: l10n.adminSubscriptionsTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminSubscriptionListScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                _AdminMenuRow(
                  icon: Icons.flag_rounded,
                  label: l10n.adminReportsTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminReportListScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A90D9), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
