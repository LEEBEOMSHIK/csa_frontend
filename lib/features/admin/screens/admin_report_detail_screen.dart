import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_report.dart';
import 'package:csa_frontend/features/admin/services/admin_report_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final int reportId;

  const AdminReportDetailScreen({super.key, required this.reportId});

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  static const _accent = Color(0xFF4A90D9);

  late Future<AdminReport> _future;
  final _noteController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminReport> _load() async {
    final report = await AdminReportService.instance.fetchReport(
      widget.reportId,
    );
    _noteController.text = report.adminNote ?? '';
    return report;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _resolve(String status) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _processing = true);
    try {
      await AdminReportService.instance.resolve(
        widget.reportId,
        status: status,
        adminNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.adminReportDetailTitle, showBack: true),
          Expanded(
            child: FutureBuilder<AdminReport>(
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
                final report = snapshot.data!;
                final isPending = report.status == 'PENDING';
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: l10n.adminReportFieldId,
                        value: '${report.id}',
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldReporter,
                        value: report.reporterEmail ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldTargetType,
                        value: report.targetType,
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldTargetId,
                        value: '${report.targetId}',
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldReason,
                        value: report.reason,
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldDetail,
                        value: report.detail ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldStatus,
                        value: report.status,
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldCreatedAt,
                        value: report.createdAt?.toString() ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminReportFieldResolvedAt,
                        value: report.resolvedAt?.toString() ?? '-',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.adminReportFieldAdminNote,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _noteController,
                        enabled: !_processing && isPending,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.adminReportNoteHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isPending) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _processing
                                ? null
                                : () => _resolve('RESOLVED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2DC653),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(l10n.adminReportResolveAction),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _processing
                                ? null
                                : () => _resolve('REJECTED'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(l10n.adminReportRejectAction),
                          ),
                        ),
                      ],
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
