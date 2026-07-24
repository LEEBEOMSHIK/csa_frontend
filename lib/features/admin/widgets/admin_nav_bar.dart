import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:csa_frontend/features/admin/screens/admin_fairytale_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_home_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_login_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_report_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_subscription_list_screen.dart';
import 'package:csa_frontend/features/admin/screens/admin_user_list_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

/// 관리자 사이트 최상위 5개 화면(대시보드/유저/동화/구독/신고)을 구분하는 섹션.
enum AdminSection { dashboard, users, fairytales, subscriptions, reports }

/// 관리자 사이트 전용 영구 네비게이션 바.
///
/// 대시보드와 4개 목록 화면 전부에서 항상 표시되어, 화면 안에 들어간 뒤에도
/// 다른 관리 메뉴로 즉시 이동할 수 있게 한다. 현재 섹션은 [current]로 표시되고
/// 하이라이트된다. 탭을 누르면 `pushReplacement`로 이동해 스택이 계속 쌓이지
/// 않는다.
class AdminNavBar extends StatelessWidget {
  final AdminSection current;

  static const Color _bg = Color(0xFFFE9EC7);
  static const Color _fg = Color(0xFF333333);

  const AdminNavBar({super.key, required this.current});

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

  void _go(BuildContext context, AdminSection section) {
    if (section == current) return;
    final Widget screen;
    switch (section) {
      case AdminSection.dashboard:
        screen = const AdminHomeScreen();
        break;
      case AdminSection.users:
        screen = const AdminUserListScreen();
        break;
      case AdminSection.fairytales:
        screen = const AdminFairytaleListScreen();
        break;
      case AdminSection.subscriptions:
        screen = const AdminSubscriptionListScreen();
        break;
      case AdminSection.reports:
        screen = const AdminReportListScreen();
        break;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(color: _bg, height: MediaQuery.of(context).padding.top),
          Container(
            color: _bg,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _NavItem(
                          label: l10n.adminMenuTitle,
                          selected: current == AdminSection.dashboard,
                          onTap: () => _go(context, AdminSection.dashboard),
                        ),
                        _NavItem(
                          label: l10n.adminUsersTitle,
                          selected: current == AdminSection.users,
                          onTap: () => _go(context, AdminSection.users),
                        ),
                        _NavItem(
                          label: l10n.adminFairytalesTitle,
                          selected: current == AdminSection.fairytales,
                          onTap: () => _go(context, AdminSection.fairytales),
                        ),
                        _NavItem(
                          label: l10n.adminSubscriptionsTitle,
                          selected: current == AdminSection.subscriptions,
                          onTap: () =>
                              _go(context, AdminSection.subscriptions),
                        ),
                        _NavItem(
                          label: l10n.adminReportsTitle,
                          selected: current == AdminSection.reports,
                          onTap: () => _go(context, AdminSection.reports),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: _fg),
                  tooltip: l10n.adminLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
              color: AdminNavBar._fg,
            ),
          ),
        ),
      ),
    );
  }
}
