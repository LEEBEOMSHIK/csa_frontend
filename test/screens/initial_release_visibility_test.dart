import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // 초기 릴리스 정책: AI 동화 "생성"은 제공하지 않는다(구독 정책이 확정되면 다시 추가될 수 있다).
  // 다만 이미 생성된 동화의 "재생" 경로는 열어 둔다 —
  // `MyFairytaleListScreen`은 목록/재생 전용 화면이라 생성 진입점이 아니므로 노출이 허용된다.
  test('AI fairytale creation entry point stays hidden', () {
    final mainScreen = File('lib/screens/main_screen.dart').readAsStringSync();
    final localeProvider = File(
      'lib/utils/locale_provider.dart',
    ).readAsStringSync();

    expect(mainScreen, isNot(contains('FairytaleCreateScreen')));
    expect(localeProvider, contains('ValueNotifier<int>(1)'));
  });
}
