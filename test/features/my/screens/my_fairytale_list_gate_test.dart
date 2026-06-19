import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/screens/my_fairytale_list_screen.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/connectivity_service.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

/// 항상 온라인으로 보고하는 connectivity source.
class _OnlineSource implements ConnectivitySource {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}

/// 서버에서 완료된 슬라이드 동화 1건을 돌려주는 fake.
class _OnlineApi implements MyFairytaleApiClient {
  @override
  Future<dynamic> get(String path) async {
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
    throw StateError('Unexpected path: $path');
  }

  @override
  Future<dynamic> post(String path) => throw UnimplementedError();

  @override
  Future<dynamic> delete(String path) => throw UnimplementedError();
}

/// downloadSlide 호출 여부만 기록하는 fake DownloadManager.
/// 저장본은 없음(isOfflineAvailable=false)으로 고정해 다운로드 버튼이 노출되게 한다.
class _RecordingDownloadManager extends DownloadManager {
  _RecordingDownloadManager()
      : super(
          fairytaleService: MyFairytaleService(api: _OnlineApi()),
        );

  int downloadCalls = 0;

  @override
  bool isOfflineAvailable(String fairytaleId) => false;

  @override
  bool isDownloading(String fairytaleId) => false;

  @override
  Future<void> downloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
  }) async {
    downloadCalls++;
  }
}

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko'), Locale('ja')],
      home: child,
    );

void main() {
  late _RecordingDownloadManager manager;
  late ConnectivityService connectivity;

  setUp(() async {
    manager = _RecordingDownloadManager();
    connectivity = ConnectivityService(source: _OnlineSource());
    await connectivity.start();
  });

  tearDown(() async {
    await connectivity.dispose();
    isPremiumNotifier.value = false;
  });

  testWidgets('FREE user tapping offline save shows upsell, no download',
      (tester) async {
    isPremiumNotifier.value = false;

    await tester.pumpWidget(
      _wrap(
        MyFairytaleListScreen(
          service: MyFairytaleService(api: _OnlineApi()),
          downloadManager: manager,
          connectivity: connectivity,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // FREE 일 때 저장 버튼은 잠금 아이콘으로 표시된다.
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.lock_outline_rounded));
    await tester.pumpAndSettle();

    // 다운로드는 시작되지 않고 업셀 안내가 노출된다.
    expect(manager.downloadCalls, 0);
    expect(find.text('오프라인 저장은 프리미엄 전용 기능이에요'), findsOneWidget);
  });

  testWidgets('PREMIUM user tapping offline save starts download',
      (tester) async {
    isPremiumNotifier.value = true;

    await tester.pumpWidget(
      _wrap(
        MyFairytaleListScreen(
          service: MyFairytaleService(api: _OnlineApi()),
          downloadManager: manager,
          connectivity: connectivity,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // PREMIUM 일 때 잠금 없이 다운로드 버튼이 표시된다.
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.download_outlined));
    await tester.pumpAndSettle();

    expect(manager.downloadCalls, 1);
    expect(find.text('오프라인 저장은 프리미엄 전용 기능이에요'), findsNothing);
  });
}
