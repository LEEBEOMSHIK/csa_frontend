import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI generation and user-created fairytale entries are hidden', () {
    final mainScreen = File('lib/screens/main_screen.dart').readAsStringSync();
    final settingsScreen = File(
      'lib/features/my/screens/my_screen.dart',
    ).readAsStringSync();
    final localeProvider = File(
      'lib/utils/locale_provider.dart',
    ).readAsStringSync();

    expect(mainScreen, isNot(contains('FairytaleCreateScreen')));
    expect(settingsScreen, isNot(contains('MyFairytaleListScreen')));
    expect(localeProvider, contains('ValueNotifier<int>(1)'));
  });
}
