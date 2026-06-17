import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:csa_frontend/features/my/screens/my_fairytale_list_screen.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/features/offline/models/offline_meta_entry.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';
import 'package:csa_frontend/features/offline/services/offline_store.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/connectivity_service.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';

class _OfflineSource implements ConnectivitySource {
  final StreamController<List<ConnectivityResult>> controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;

  Future<void> close() => controller.close();
}

/// 서버를 호출하면 즉시 실패시켜, 오프라인일 때 fetch 가 일어나지 않음을 검증한다.
class _FailingApi implements MyFairytaleApiClient {
  bool getCalled = false;

  @override
  Future<dynamic> get(String path) async {
    getCalled = true;
    throw StateError('server should not be reached while offline');
  }

  @override
  Future<dynamic> post(String path) => throw UnimplementedError();

  @override
  Future<dynamic> delete(String path) => throw UnimplementedError();
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
  late Directory tempDir;
  late Box<OfflineSlideEntry> slideBox;
  late Box<OfflineMetaEntry> metaBox;
  late DownloadManager manager;
  late ConnectivityService connectivity;
  late _OfflineSource source;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_screen_test');
    Hive.init('${tempDir.path}/hive');
    OfflineStore.instance.registerAdaptersForTest();
    slideBox = await Hive.openBox<OfflineSlideEntry>('offline_slide_box');
    metaBox = await Hive.openBox<OfflineMetaEntry>('offline_meta_box');
    OfflineStore.instance.initForTest(slideBox: slideBox, metaBox: metaBox);

    manager = DownloadManager(
      fairytaleService: MyFairytaleService(api: _FailingApi()),
      store: OfflineStore.instance,
      documentsDirProvider: () async => tempDir,
    );

    // 저장 완료된 동화 한 건을 시드한다.
    await slideBox.put(
      '5',
      OfflineSlideEntry(
        fairytaleId: '5',
        title: '저장된 동화',
        thumbnailLocalPath: '',
        pages: const [
          OfflineSlidePage(
            pageIndex: 1,
            text: '저장 페이지',
            localImagePath: '',
            localAudioPaths: {},
          ),
        ],
        downloadedAt: DateTime.now(),
      ),
    );
    await metaBox.put(
      '5',
      OfflineMetaEntry(
        fairytaleId: '5',
        format: 'slide',
        totalSizeBytes: 100,
        downloadedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        status: DownloadStatus.completed,
      ),
    );

    source = _OfflineSource();
    connectivity = ConnectivityService(source: source);
    await connectivity.start();
  });

  tearDown(() async {
    await connectivity.dispose();
    await source.close();
    await slideBox.deleteFromDisk();
    await metaBox.deleteFromDisk();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('offline shows banner and only saved fairytales', (tester) async {
    final api = _FailingApi();
    await tester.pumpWidget(
      _wrap(
        MyFairytaleListScreen(
          service: MyFairytaleService(api: api),
          downloadManager: manager,
          connectivity: connectivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // 서버 호출 없이 저장본만 노출
    expect(api.getCalled, isFalse);
    expect(find.text('저장된 동화'), findsOneWidget);
    // 오프라인 배너 문구
    expect(find.text('오프라인 상태예요. 저장한 동화만 볼 수 있어요'), findsOneWidget);

    // 화면 트리를 해제해 리스너/박스 참조를 정리한다.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('offline empty state when nothing saved', (tester) async {
    // Hive 디스크 I/O 는 실제 async 이므로 runAsync 안에서 수행한다.
    await tester.runAsync(() async {
      await slideBox.delete('5');
      await metaBox.delete('5');
    });

    await tester.pumpWidget(
      _wrap(
        MyFairytaleListScreen(
          service: MyFairytaleService(api: _FailingApi()),
          downloadManager: manager,
          connectivity: connectivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('오프라인에 저장한 동화가 없어요'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
