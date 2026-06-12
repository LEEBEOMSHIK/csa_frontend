import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/features/my/screens/my_fairytale_list_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

void main() {
  testWidgets('opens completed slide fairytale from my list', (tester) async {
    final api = _FakeMyFairytaleApiClient();
    final service = MyFairytaleService(api: api);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('ja')],
        home: MyFairytaleListScreen(service: service),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('별빛 모험'));
    await tester.pumpAndSettle();

    expect(api.requestedPaths, contains('/fairytale/7/slides'));
    expect(find.text('첫 페이지'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });
}

class _FakeMyFairytaleApiClient implements MyFairytaleApiClient {
  final List<String> requestedPaths = [];

  @override
  Future<dynamic> get(String path) async {
    requestedPaths.add(path);
    if (path == '/fairytale/my') {
      return [
        {
          'id': 7,
          'title': '별빛 모험',
          'format': 'slide',
          'status': 'COMPLETED',
          'language': 'ko',
          'shared': false,
          'thumbnailUrl': null,
          'pageCount': 1,
        },
      ];
    }
    if (path == '/fairytale/7/slides') {
      return {
        'id': 7,
        'title': '별빛 모험',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {'pageIndex': 1, 'text': '첫 페이지'},
        ],
      };
    }
    throw StateError('Unexpected path: $path');
  }

  @override
  Future<dynamic> post(String path) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(String path) {
    throw UnimplementedError();
  }
}
