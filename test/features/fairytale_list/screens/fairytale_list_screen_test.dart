import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/fairytale_list/screens/fairytale_list_screen.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('ko'),
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
  tearDown(() {
    isPremiumNotifier.value = false;
  });

  testWidgets('opens a shared fairytale from shared tab', (tester) async {
    final api = _FakeSharedApi();
    final service = MyFairytaleService(api: api);

    await tester.pumpWidget(
      _wrap(
        FairytaleListScreen(
          service: service,
          catalogService: _FakeCatalogService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('🌟 공유 동화'));
    await tester.pumpAndSettle();

    expect(api.requestedPaths, contains('/fairytale/shared'));
    expect(find.text('별빛 모험'), findsOneWidget);

    await tester.tap(find.text('별빛 모험'));
    await tester.pumpAndSettle();

    expect(api.requestedPaths, contains('/fairytale/shared/7/slides'));
    expect(find.text('공유 첫 페이지'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('premium save on shared tab downloads through shared path', (
    tester,
  ) async {
    isPremiumNotifier.value = true;
    final api = _FakeSharedApi();
    final manager = _RecordingDownloadManager();

    await tester.pumpWidget(
      _wrap(
        FairytaleListScreen(
          service: MyFairytaleService(api: api),
          downloadManager: manager,
          catalogService: _FakeCatalogService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('🌟 공유 동화'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.download_outlined));
    await tester.pumpAndSettle();

    expect(manager.downloadCalls, 1);
    expect(manager.lastFairytaleId, 7);
    expect(manager.lastShared, isTrue);
  });

  testWidgets('renders classic fairytales on the default classic tab', (
    tester,
  ) async {
    final catalog = _FakeCatalogService(
      items: const [
        FairytaleItem(id: 1, title: '고전 동화 A', categories: []),
        FairytaleItem(id: 2, title: '고전 동화 B', categories: []),
      ],
    );

    await tester.pumpWidget(
      _wrap(
        FairytaleListScreen(
          service: MyFairytaleService(api: _FakeSharedApi()),
          catalogService: catalog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('고전 동화 A'), findsOneWidget);
    expect(find.text('고전 동화 B'), findsOneWidget);
  });

  testWidgets('tapping a category chip reloads with category param', (
    tester,
  ) async {
    final catalog = _FakeCatalogService(
      items: const [FairytaleItem(id: 1, title: '고전 동화 A', categories: [])],
      categories: const [
        FairytaleCategory(
          categoryKey: 'adventure',
          nameKo: '모험',
          nameJa: 'ぼうけん',
          count: 3,
        ),
      ],
    );

    await tester.pumpWidget(
      _wrap(
        FairytaleListScreen(
          service: MyFairytaleService(api: _FakeSharedApi()),
          catalogService: catalog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(catalog.requestedCategories.last, isNull);

    await tester.tap(find.text('#모험'));
    await tester.pumpAndSettle();

    expect(catalog.requestedCategories.last, 'adventure');
  });
}

class _FakeCatalogService implements CatalogService {
  final List<FairytaleItem> items;
  final List<FairytaleCategory> categories;

  final List<String?> requestedCategories = [];
  final List<String?> requestedSorts = [];

  _FakeCatalogService({this.items = const [], this.categories = const []});

  @override
  Future<List<FairytaleItem>> getFairytales({
    String? category,
    String? sort,
  }) async {
    requestedCategories.add(category);
    requestedSorts.add(sort);
    return items;
  }

  @override
  Future<List<FairytaleCategory>> getCategories() async => categories;
}

class _FakeSharedApi implements MyFairytaleApiClient {
  final List<String> requestedPaths = [];

  @override
  Future<dynamic> get(String path) async {
    requestedPaths.add(path);
    if (path == '/fairytale/shared') {
      return [
        {
          'id': 7,
          'title': '별빛 모험',
          'format': 'slide',
          'status': 'COMPLETED',
          'language': 'ko',
          'shared': true,
          'thumbnailUrl': null,
          'pageCount': 1,
        },
      ];
    }
    if (path == '/fairytale/shared/7/slides') {
      return {
        'id': 7,
        'title': '별빛 모험',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {'pageIndex': 1, 'text': '공유 첫 페이지'},
        ],
      };
    }
    throw StateError('Unexpected path: $path');
  }

  @override
  Future<dynamic> post(String path) => throw UnimplementedError();

  @override
  Future<dynamic> delete(String path) => throw UnimplementedError();
}

class _RecordingDownloadManager extends DownloadManager {
  _RecordingDownloadManager()
    : super(fairytaleService: MyFairytaleService(api: _FakeSharedApi()));

  int downloadCalls = 0;
  int? lastFairytaleId;
  bool? lastShared;

  @override
  bool isOfflineAvailable(String fairytaleId) => false;

  @override
  bool isDownloading(String fairytaleId) => false;

  @override
  Future<void> downloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
    bool shared = false,
  }) async {
    downloadCalls++;
    lastFairytaleId = fairytaleId;
    lastShared = shared;
  }
}
