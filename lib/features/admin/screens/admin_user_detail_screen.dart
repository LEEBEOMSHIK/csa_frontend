import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_user.dart';
import 'package:csa_frontend/features/admin/services/admin_user_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  static const _accent = Color(0xFF4A90D9);

  late Future<AdminUser> _future;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _future = AdminUserService.instance.fetchUser(widget.userId);
  }

  void _reload() {
    setState(() {
      _future = AdminUserService.instance.fetchUser(widget.userId);
    });
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final nextStatus = user.isActive ? 'SUSPENDED' : 'ACTIVE';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          user.isActive
              ? l10n.adminUserSuspendConfirmTitle
              : l10n.adminUserActivateConfirmTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          user.isActive
              ? l10n.adminUserSuspendConfirmMessage
              : l10n.adminUserActivateConfirmMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.adminCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.adminConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updating = true);
    try {
      await AdminUserService.instance.updateStatus(user.id, nextStatus);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminActionSuccess)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminActionError)));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.adminUserDetailTitle),
          Expanded(
            child: FutureBuilder<AdminUser>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accent),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.adminLoadError));
                }
                final user = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: l10n.adminUserFieldId,
                        value: '${user.id}',
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldEmail,
                        value: user.email,
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldName,
                        value: user.name ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldProvider,
                        value: user.provider ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldRole,
                        value: user.role,
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldStatus,
                        value: user.isActive
                            ? l10n.adminUserStatusActive
                            : l10n.adminUserStatusSuspended,
                      ),
                      _InfoRow(
                        label: l10n.adminUserFieldCreatedAt,
                        value: user.createdAt?.toString() ?? '-',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updating
                              ? null
                              : () => _toggleStatus(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: user.isActive
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF2DC653),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            user.isActive
                                ? l10n.adminUserSuspendAction
                                : l10n.adminUserActivateAction,
                          ),
                        ),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
