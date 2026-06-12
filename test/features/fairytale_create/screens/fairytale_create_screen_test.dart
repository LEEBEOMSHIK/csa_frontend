import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/fairytale_create/screens/fairytale_create_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

void main() {
  Future<void> tapVisible(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('video format is visible but does not start generation yet', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ko'), Locale('ja')],
        home: FairytaleCreateScreen(),
      ),
    );

    await tapVisible(tester, '모험');
    await tapVisible(tester, '클래식');
    await tapVisible(tester, '교훈·도덕');
    await tapVisible(tester, '3챕터');
    await tapVisible(tester, '사용 안함');
    await tapVisible(tester, '아빠');

    await tester.tap(find.text('동화 만들기!'));
    await tester.pumpAndSettle();

    expect(find.text('영상 형식'), findsOneWidget);

    await tester.tap(find.text('영상 형식'));
    await tester.pump();

    expect(find.text('AI가 동화를 만들고 있어요...'), findsNothing);
  });
}
