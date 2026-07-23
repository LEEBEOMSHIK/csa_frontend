import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/features/admin/models/admin_user.dart';
import 'package:csa_frontend/features/admin/screens/admin_user_detail_screen.dart';
import 'package:csa_frontend/features/admin/services/admin_user_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  static const _accent = Color(0xFF4A90D9);

  final _searchController = TextEditingController();
  String? _query;
  int _page = 0;
  late Future<AdminPageResponse<AdminUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<AdminPageResponse<AdminUser>> _load() {
    return AdminUserService.instance.fetchUsers(q: _query, page: _page);
  }

  void _reload() => setState(() => _future = _load());

  void _onSearch(String value) {
    _page = 0;
    _query = value.trim().isEmpty ? null : value.trim();
    _reload();
  }

  void _goToPage(int page) {
    _page = page;
    _reload();
  }

  Future<void> _openDetail(AdminUser user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AdminUserDetailScreen(userId: user.id)),
    );
    // 상세 화면에서 상태가 변경됐을 수 있으므로 복귀 시 항상 갱신한다.
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.adminUsersTitle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.adminSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => _onSearch(_searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<AdminPageResponse<AdminUser>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accent),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorView(
                    message: _errorMessage(l10n, snapshot.error),
                    onRetry: _reload,
                  );
                }
                final result = snapshot.data!;
                if (result.content.isEmpty) {
                  return Center(child: Text(l10n.adminEmptyList));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: result.content.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final user = result.content[i];
                          return _UserRow(
                            user: user,
                            onTap: () => _openDetail(user),
                          );
                        },
                      ),
                    ),
                    _PaginationBar(
                      page: result.page,
                      totalPages: result.totalPages,
                      onPrev: result.hasPrev
                          ? () => _goToPage(result.page - 1)
                          : null,
                      onNext: result.hasNext
                          ? () => _goToPage(result.page + 1)
                          : null,
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

  String _errorMessage(AppLocalizations l10n, Object? error) {
    if (error is ApiException) return error.message;
    return l10n.adminLoadError;
  }
}

class _UserRow extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserRow({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name?.isNotEmpty == true ? user.name! : user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _StatusChip(
              label: user.isActive
                  ? l10n.adminUserStatusActive
                  : l10n.adminUserStatusSuspended,
              active: user.isActive,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2DC653) : const Color(0xFFFF6B6B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${totalPages == 0 ? 0 : page + 1} / $totalPages',
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          Text(message, style: const TextStyle(color: Color(0xFF999999))),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l10n.adminRetry)),
        ],
      ),
    );
  }
}
