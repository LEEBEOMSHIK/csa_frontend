import 'package:flutter/material.dart';

import 'package:csa_frontend/features/report/widgets/report_dialog.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/app_colors.dart';

/// [ReportButton]의 표시 형태.
/// - [overlay]: 썸네일 위에 올리는 흰 원형 버튼 (공유 동화 카드)
/// - [topBar]: 화면 상단 바에 들어가는 평범한 아이콘 버튼 (재생 화면)
enum ReportButtonVariant { overlay, topBar }

/// 공유 동화 신고 진입 버튼. 탭하면 신고 대상(콘텐츠/작성자) 선택 시트를 띄우고
/// 선택한 대상으로 [ReportDialog]를 연다. [ownerId]가 null이면 작성자 신고
/// 항목을 감춘다.
class ReportButton extends StatelessWidget {
  final AppLocalizations l10n;
  final int fairytaleId;
  final int? ownerId;
  final ReportButtonVariant variant;

  const ReportButton({
    super.key,
    required this.l10n,
    required this.fairytaleId,
    this.ownerId,
    this.variant = ReportButtonVariant.overlay,
  });

  void _openReportDialog(
    BuildContext context,
    String targetType,
    int targetId,
  ) {
    showDialog(
      context: context,
      builder: (_) => ReportDialog(targetType: targetType, targetId: targetId),
    );
  }

  void _openMenu(BuildContext context) {
    final owner = ownerId;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.reportMenuTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l10n.reportContentOption),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openReportDialog(context, 'CONTENT', fairytaleId);
                },
              ),
              if (owner != null)
                ListTile(
                  leading: const Icon(Icons.person_off_outlined),
                  title: Text(l10n.reportUserOption),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openReportDialog(context, 'USER', owner);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == ReportButtonVariant.topBar) {
      return IconButton(
        tooltip: l10n.reportButtonLabel,
        onPressed: () => _openMenu(context),
        icon: const Icon(
          Icons.flag_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: l10n.reportButtonLabel,
        onPressed: () => _openMenu(context),
        icon: const Icon(Icons.flag_outlined, color: Color(0xFF777777)),
        iconSize: 18,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
