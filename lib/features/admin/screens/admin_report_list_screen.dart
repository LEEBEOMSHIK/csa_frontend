import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_page_response.dart';
import 'package:csa_frontend/features/admin/models/admin_report.dart';
import 'package:csa_frontend/features/admin/screens/admin_report_detail_screen.dart';
import 'package:csa_frontend/features/admin/services/admin_report_service.dart';
import 'package:csa_frontend/features/admin/widgets/admin_nav_bar.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class AdminReportListScreen extends StatefulWidget {
  const AdminReportListScreen({super.key});

  @override
  State<AdminReportListScreen> createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends State<AdminReportListScreen> {
  static const _accent = Color(0xFF4A90D9);

  String _status = 'PENDING';
  String? _targetType;
  int _page = 0;
  late Future<AdminPageResponse<AdminReport>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminPageResponse<AdminReport>> _load() {
    return AdminReportService.instance.fetchReports(
      status: _status,
      targetType: _targetType,
      page: _page,
    );
  }

  void _reload() => setState(() => _future = _load());

  void _goToPage(int page) {
    _page = page;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          const AdminNavBar(current: AdminSection.reports),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    hint: l10n.adminReportFilterStatus,
                    value: _status,
                    items: const ['PENDING', 'RESOLVED', 'REJECTED'],
                    labelBuilder: (v) => _statusLabel(l10n, v),
                    onChanged: (v) {
                      _status = v ?? 'PENDING';
                      _page = 0;
                      _reload();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterDropdown(
                    hint: l10n.adminReportFilterType,
                    value: _targetType,
                    items: const ['CONTENT', 'USER'],
                    allowClear: true,
                    onChanged: (v) {
                      _targetType = v;
                      _page = 0;
                      _reload();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<AdminPageResponse<AdminReport>>(
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
                        padding: const EdgeInsets.all(16),
                        itemCount: result.content.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = result.content[i];
                          return _ReportRow(
                            item: item,
                            statusLabel: _statusLabel(l10n, item.status),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminReportDetailScreen(reportId: item.id),
                                ),
                              );
                              _reload();
                            },
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

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'RESOLVED':
        return l10n.adminReportStatusResolved;
      case 'REJECTED':
        return l10n.adminReportStatusRejected;
      default:
        return l10n.adminReportStatusPending;
    }
  }

  String _errorMessage(AppLocalizations l10n, Object? error) {
    if (error is ApiException) return error.message;
    return l10n.adminLoadError;
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final String Function(String)? labelBuilder;
  final bool allowClear;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
    this.allowClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          items: [
            if (allowClear)
              DropdownMenuItem<String>(value: null, child: Text(hint)),
            ...items.map(
              (v) => DropdownMenuItem<String>(
                value: v,
                child: Text(labelBuilder?.call(v) ?? v),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final AdminReport item;
  final String statusLabel;
  final VoidCallback onTap;

  const _ReportRow({
    required this.item,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    '${item.targetType} #${item.targetId} · ${item.reason}',
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
                    item.reporterEmail ?? '-',
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
            Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A90D9),
              ),
            ),
          ],
        ),
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
