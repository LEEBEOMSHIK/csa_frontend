import 'package:flutter/material.dart';

import 'package:csa_frontend/features/admin/models/admin_subscription.dart';
import 'package:csa_frontend/features/admin/services/admin_subscription_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

/// 구독 상세 — 읽기 전용. 구독 tier/status는 스토어 영수증 검증으로만
/// 갱신되는 정책이라 관리자가 수정할 수 있는 액션 버튼은 두지 않는다.
class AdminSubscriptionDetailScreen extends StatefulWidget {
  final int subscriptionId;

  const AdminSubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<AdminSubscriptionDetailScreen> createState() =>
      _AdminSubscriptionDetailScreenState();
}

class _AdminSubscriptionDetailScreenState
    extends State<AdminSubscriptionDetailScreen> {
  static const _accent = Color(0xFF4A90D9);

  late Future<AdminSubscription> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminSubscriptionService.instance.fetchSubscription(
      widget.subscriptionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.adminSubscriptionDetailTitle),
          Expanded(
            child: FutureBuilder<AdminSubscription>(
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
                        label: l10n.adminSubscriptionFieldId,
                        value: '${item.id}',
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldUser,
                        value: item.userEmail ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldPlatform,
                        value: item.platform,
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldProductId,
                        value: item.productId,
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldStatus,
                        value: item.status,
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldEnvironment,
                        value: item.environment,
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldPeriodEnd,
                        value: item.currentPeriodEnd?.toString() ?? '-',
                      ),
                      _InfoRow(
                        label: l10n.adminSubscriptionFieldAutoRenew,
                        value: item.autoRenew
                            ? l10n.adminFairytaleSharedYes
                            : l10n.adminFairytaleSharedNo,
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
            width: 110,
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
