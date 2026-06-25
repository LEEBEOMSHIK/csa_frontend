import 'package:flutter/material.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/features/my/models/user_settings.dart';
import 'package:csa_frontend/features/my/screens/my_fairytale_list_screen.dart';
import 'package:csa_frontend/features/my/screens/offline_storage_screen.dart';
import 'package:csa_frontend/features/my/screens/premium_purchase_screen.dart';
import 'package:csa_frontend/features/my/services/user_settings_service.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/byte_format.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

const String _currentTermVersion = 'v1.0';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _textNotiEnabled = textNotiNotifier.value;
  bool _pushNotiEnabled = pushNotiNotifier.value;

  final _settingsService = UserSettingsService.instance;
  final _downloadManager = DownloadManager.instance;

  int _offlineCount = 0;
  int _offlineBytes = 0;

  @override
  void initState() {
    super.initState();
    textNotiNotifier.addListener(_syncNotiFromNotifiers);
    pushNotiNotifier.addListener(_syncNotiFromNotifiers);
    _refreshOfflineSummary();
  }

  void _refreshOfflineSummary() {
    if (!mounted) return;
    setState(() {
      _offlineCount = _downloadManager.savedCount();
      _offlineBytes = _downloadManager.totalUsedBytes();
    });
  }

  Future<void> _openOfflineStorage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OfflineStorageScreen()));
    // 목록 화면에서 삭제가 일어났을 수 있으므로 복귀 시 요약을 갱신한다.
    _refreshOfflineSummary();
  }

  @override
  void dispose() {
    textNotiNotifier.removeListener(_syncNotiFromNotifiers);
    pushNotiNotifier.removeListener(_syncNotiFromNotifiers);
    super.dispose();
  }

  void _syncNotiFromNotifiers() {
    if (!mounted) return;
    setState(() {
      _textNotiEnabled = textNotiNotifier.value;
      _pushNotiEnabled = pushNotiNotifier.value;
    });
  }

  UserSettings _currentSettings() => UserSettings(
    locale: localeNotifier.value.languageCode,
    textNotiEnabled: _textNotiEnabled,
    pushNotiEnabled: _pushNotiEnabled,
  );

  String get _selectedLanguageName =>
      localeNotifier.value.languageCode == 'ja' ? '日本語' : '한국어';

  Future<void> _changeLanguage(String languageCode) async {
    final previous = localeNotifier.value;
    if (previous.languageCode == languageCode) return;
    try {
      final updated = await _settingsService.updateSettings(
        _currentSettings().copyWith(locale: languageCode),
      );
      localeNotifier.value = Locale(updated.locale);
    } catch (_) {
      localeNotifier.value = previous;
      _showSaveError();
    }
    if (mounted) setState(() {});
  }

  Future<void> _changeNoti({bool? text, bool? push}) async {
    final prevText = _textNotiEnabled;
    final prevPush = _pushNotiEnabled;
    setState(() {
      if (text != null) _textNotiEnabled = text;
      if (push != null) _pushNotiEnabled = push;
    });
    try {
      final updated = await _settingsService.updateSettings(_currentSettings());
      textNotiNotifier.value = updated.textNotiEnabled;
      pushNotiNotifier.value = updated.pushNotiEnabled;
    } catch (_) {
      setState(() {
        _textNotiEnabled = prevText;
        _pushNotiEnabled = prevPush;
      });
      _showSaveError();
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaveError)));
  }

  Future<void> _agreeTerm(TermType type, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsTermAgreeTitle),
          content: Text(l10n.settingsTermAgreeMessage(title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsTermAgreeCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsTermAgreeConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await _settingsService.agreeTerm(type, _currentTermVersion);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsTermAgreed)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsTermAgreeError)));
    }
  }

  void _showLanguagePicker(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.settingsLanguageTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                _LanguageOption(
                  label: '한국어',
                  isSelected: localeNotifier.value.languageCode == 'ko',
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage('ko');
                  },
                ),
                _LanguageOption(
                  label: '日本語',
                  isSelected: localeNotifier.value.languageCode == 'ja',
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage('ja');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          AppTopBar(title: l10n.settingsTitle),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 버전 정보
                  _SettingRow(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.settingsVersion,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _ThickDivider(),
                  // 프로필 및 계정
                  _SettingRow(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.settingsProfile,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
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
                  const _ThickDivider(),
                  // 활동 내역 섹션
                  _SectionHeader(title: l10n.settingsSectionActivity),
                  _SubRow(
                    label: l10n.settingsMyFairytales,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyFairytaleListScreen(),
                      ),
                    ),
                  ),
                  _SubRow(
                    label: l10n.settingsPurchaseHistory,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PremiumPurchaseScreen(),
                      ),
                    ),
                  ),
                  _SubRow(label: l10n.settingsFavoriteHistory, onTap: () {}),
                  const _ThickDivider(),
                  // 동화 설정
                  _SettingRow(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.settingsFairytaleConfig,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
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
                  const _ThickDivider(),
                  // 혜택 및 이벤트 알림 섹션
                  _SectionHeader(title: l10n.settingsSectionNoti),
                  _ToggleRow(
                    label: l10n.settingsTextNoti,
                    value: _textNotiEnabled,
                    onChanged: (v) => _changeNoti(text: v),
                  ),
                  _ToggleRow(
                    label: l10n.settingsPushNoti,
                    value: _pushNotiEnabled,
                    onChanged: (v) => _changeNoti(push: v),
                  ),
                  const _ThickDivider(),
                  // 앱 설정 섹션
                  _SectionHeader(title: l10n.settingsSectionApp),
                  _ValueRow(
                    label: l10n.settingsLanguage,
                    value: _selectedLanguageName,
                    onTap: () => _showLanguagePicker(l10n),
                  ),
                  _ValueRow(
                    label: l10n.offlineStorageTitle,
                    value: l10n.offlineStorageSummary(
                      _offlineCount,
                      formatBytes(_offlineBytes),
                    ),
                    onTap: _openOfflineStorage,
                  ),
                  const _ThickDivider(),
                  // 기기 설정 섹션
                  _SectionHeader(title: l10n.settingsSectionDevice),
                  _SubRow(label: l10n.settingsCameraAccess, onTap: () {}),
                  const _ThickDivider(),
                  // 약관 및 정책 섹션
                  _SectionHeader(title: l10n.settingsSectionPolicy),
                  _SubRow(
                    label: l10n.settingsTerms,
                    onTap: () =>
                        _agreeTerm(TermType.service, l10n.settingsTerms),
                  ),
                  _SubRow(
                    label: l10n.settingsFinanceTerms,
                    onTap: () =>
                        _agreeTerm(TermType.finance, l10n.settingsFinanceTerms),
                  ),
                  _SubRow(
                    label: l10n.settingsPrivacy,
                    onTap: () =>
                        _agreeTerm(TermType.privacy, l10n.settingsPrivacy),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThickDivider extends StatelessWidget {
  const _ThickDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: const Color(0xFFF5F5F5));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF333333),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SettingRow({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white,
        child: child,
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SubRow({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 36, right: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ValueRow({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 36, right: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : const Color(0xFF333333),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Color(0xFF4A90D9),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 36, right: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF4A90D9)
                    : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
