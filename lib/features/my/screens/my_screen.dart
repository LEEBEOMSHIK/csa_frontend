import 'package:flutter/material.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _textNotiEnabled = true;
  bool _pushNotiEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          const AppTopBar(title: '설정'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 버전 정보
                  _SettingRow(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '현재 버전',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
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
                      children: const [
                        Text(
                          '프로필 및 계정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const _ThickDivider(),
                  // 활동 내역 섹션
                  const _SectionHeader(title: '활동 내역'),
                  _SubRow(label: '구매 내역', onTap: () {}),
                  _SubRow(label: '찜 목록 내역', onTap: () {}),
                  const _ThickDivider(),
                  // 동화 설정
                  _SettingRow(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '동화 설정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const _ThickDivider(),
                  // 혜택 및 이벤트 알림 섹션
                  const _SectionHeader(title: '혜택 및 이벤트 알림'),
                  _ToggleRow(
                    label: '문자 알림',
                    value: _textNotiEnabled,
                    onChanged: (v) => setState(() => _textNotiEnabled = v),
                  ),
                  _ToggleRow(
                    label: '푸시 알림',
                    value: _pushNotiEnabled,
                    onChanged: (v) => setState(() => _pushNotiEnabled = v),
                  ),
                  const _ThickDivider(),
                  // 기기 설정 섹션
                  const _SectionHeader(title: '기기 설정'),
                  _SubRow(label: '카메라 접근', onTap: () {}),
                  const _ThickDivider(),
                  // 약관 및 정책 섹션
                  const _SectionHeader(title: '약관 및 정책'),
                  _SubRow(label: '서비스 이용약관', onTap: () {}),
                  _SubRow(label: '전자금융거래 이용약관', onTap: () {}),
                  _SubRow(label: '개인정보처리방침', onTap: () {}),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
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
                color: value ? const Color(0xFF4A90D9) : const Color(0xFFCCCCCC),
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
