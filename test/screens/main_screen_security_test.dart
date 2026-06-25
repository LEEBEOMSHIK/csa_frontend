import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login debug panel and token forwarding are removed', () {
    final mainScreen = File('lib/screens/main_screen.dart').readAsStringSync();
    final loginScreen = File(
      'lib/features/auth/screens/login_screen.dart',
    ).readAsStringSync();

    expect(mainScreen, isNot(contains('[DEBUG] /auth/login response')));
    expect(mainScreen, isNot(contains('_DebugDataPanel')));
    expect(loginScreen, isNot(contains('debugData:')));
    expect(loginScreen, isNot(contains('...tokens')));
  });
}
