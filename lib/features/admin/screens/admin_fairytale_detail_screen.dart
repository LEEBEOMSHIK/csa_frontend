import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_fairytale.dart';
import 'package:csa_frontend/features/admin/services/admin_fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class AdminFairytaleDetailScreen extends StatefulWidget {
  final int fairytaleId;

  const AdminFairytaleDetailScreen({super.key, required this.fairytaleId});

  @override
  State<AdminFairytaleDetailScreen> createState() =>
      _AdminFairytaleDetailScreenState();
}

class _AdminFairytaleDetailScreenState
    extends State<AdminFairytaleDetailScreen> {
  static const _accent = Color(0xFF4A90D9);

  late Future<AdminFairytale> _future;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _future = AdminFairytaleService.instance.fetchFairytale(
      widget.fairytaleId,
    );
  }

  void _reload() {
    setState(() {
      _future = AdminFairytaleService.instance.fetchFairytale(
        widget.fairytaleId,
      );
    });
  }

  Future<void> _unshare() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.adminFairytaleUnshareConfirmTitle,
      message: l10n.adminFairytaleUnshareConfirmMessage,
    );
    if (confirmed != true) return;

    setState(() => _processing = true);
    try {
      await AdminFairytaleService.instance.unshare(widget.fairytaleId);
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
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.adminFairytaleDeleteConfirmTitle,
      message: l10n.adminFairytaleDeleteConfirmMessage,
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _processing = true);
    try {
      await AdminFairytaleService.instance.deleteFairytale(
        widget.fairytaleId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminActionError)));
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    bool destructive = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.adminCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.adminConfirm,
              style: TextStyle(color: destructive ? Colors.red : null),
            ),
          ),
        ],
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
          AppTopBar(title: l10n.adminFairytaleDetailTitle, showBack: true),
          Expanded(
            child: FutureBuilder<AdminFairytale>(
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
                final item = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: l10n.adminFairytaleFieldId,
                        value: '${item.id}',
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldTitle,
                        value: item.title,
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldOwner,
                        value: item.ownerEmail ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldFormat,
                        value: item.format,
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldStatus,
                        value: item.status,
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldLanguage,
                        value: item.language,
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldShared,
                        value: item.shared
                            ? l10n.adminFairytaleSharedYes
                            : l10n.adminFairytaleSharedNo,
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldChapterCount,
                        value: '${item.chapterCount}',
                      ),
                      _InfoRow(
                        label: l10n.adminFairytaleFieldCreatedAt,
                        value: item.createdAt?.toString() ?? '-',
                      ),
                      const SizedBox(height: 24),
                      if (item.shared)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _processing ? null : _unshare,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(l10n.adminFairytaleUnshareAction),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _processing ? null : _delete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.adminFairytaleDeleteAction),
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
