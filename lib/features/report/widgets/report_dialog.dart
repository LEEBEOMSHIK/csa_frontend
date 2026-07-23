import 'package:flutter/material.dart';

import 'package:csa_frontend/features/report/services/report_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

/// 재사용 가능한 신고 다이얼로그. [targetType]은 "CONTENT" | "USER".
/// 호출부에서 `showDialog(context: context, builder: (_) => ReportDialog(...))`
/// 형태로 띄운다. 성공 시 다이얼로그를 닫고 스낵바로 안내한다.
class ReportDialog extends StatefulWidget {
  final String targetType;
  final int targetId;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

enum _ReportReason { inappropriate, spam, other }

extension on _ReportReason {
  /// 서버로 전송하는 사유 코드
  String get code {
    switch (this) {
      case _ReportReason.inappropriate:
        return 'INAPPROPRIATE';
      case _ReportReason.spam:
        return 'SPAM';
      case _ReportReason.other:
        return 'OTHER';
    }
  }
}

class _ReportDialogState extends State<ReportDialog> {
  _ReportReason _selected = _ReportReason.inappropriate;
  final _detailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ReportService.instance.createReport(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reason: _selected.code,
        detail: _detailController.text.trim().isEmpty
            ? null
            : _detailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportSuccess)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.reportDialogTitle,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportReasonLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
              ),
            ),
            RadioGroup<_ReportReason>(
              groupValue: _selected,
              onChanged: (v) {
                if (_submitting) return;
                setState(() => _selected = v ?? _selected);
              },
              child: Column(
                children: _ReportReason.values
                    .map(
                      (reason) => RadioListTile<_ReportReason>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: reason,
                        title: Text(_labelFor(l10n, reason)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailController,
              enabled: !_submitting,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.reportDetailHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.reportCancel),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            l10n.reportSubmit,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  String _labelFor(AppLocalizations l10n, _ReportReason reason) {
    switch (reason) {
      case _ReportReason.inappropriate:
        return l10n.reportReasonInappropriate;
      case _ReportReason.spam:
        return l10n.reportReasonSpam;
      case _ReportReason.other:
        return l10n.reportReasonOther;
    }
  }
}
