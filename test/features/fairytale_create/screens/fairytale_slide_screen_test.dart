import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_slide_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

void main() {
  testWidgets('shows generated pages and moves between slides', (tester) async {
    final response = FairytaleGenerateResponse(
      id: 1,
      title: '별빛 모험',
      pages: const [
        FairytalePageResponse(pageIndex: 1, text: '첫 번째 페이지입니다.'),
        FairytalePageResponse(pageIndex: 2, text: '두 번째 페이지입니다.'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('ja')],
        home: FairytaleSlideScreen(
          fairytale: response,
          lang: 'ko',
          voiceType: 'dad',
        ),
      ),
    );

    expect(find.text('별빛 모험'), findsOneWidget);
    expect(find.text('첫 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('slide-next-button')));
    await tester.pumpAndSettle();

    expect(find.text('두 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('slide-prev-button')));
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });
}
